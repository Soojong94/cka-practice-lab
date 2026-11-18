const express = require('express');
const { execSync, exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const { marked } = require('marked');

const app = express();
const PORT = 3000;

// 문제 디렉토리 경로
const PROBLEMS_DIR = path.join(__dirname, 'problems');

// ANSI 색상 코드 제거
function stripAnsi(str) {
  return str.replace(/\x1B\[[0-9;]*[a-zA-Z]/g, '');
}

// 문제 목록 가져오기
function getProblems() {
  const dirs = fs.readdirSync(PROBLEMS_DIR)
    .filter(d => /^\d{3}$/.test(d))
    .sort();

  return dirs.map(dir => {
    const problemPath = path.join(PROBLEMS_DIR, dir, 'problem.md');
    let title = `Problem ${dir}`;
    let domain = '';
    let time = '';

    if (fs.existsSync(problemPath)) {
      const content = fs.readFileSync(problemPath, 'utf-8');
      // 제목 추출
      const titleMatch = content.match(/^# (.+)/m);
      if (titleMatch) title = titleMatch[1];
      // 도메인 추출
      const domainMatch = content.match(/\| 도메인 \| (.+?) \|/);
      if (domainMatch) domain = domainMatch[1].trim();
      // 시간 추출
      const timeMatch = content.match(/\| 예상 소요 시간 \| (.+?) \|/);
      if (timeMatch) time = timeMatch[1].trim();
    }

    return { id: dir, title, domain, time };
  });
}

// 도메인별 색상
const DOMAIN_COLORS = {
  'Storage': '#4CAF50',
  'Troubleshooting': '#f44336',
  'Workloads & Scheduling': '#2196F3',
  'Cluster Architecture, Installation & Configuration': '#FF9800',
  'Cluster Architecture': '#FF9800',
  'Services & Networking': '#9C27B0',
  'Configuration': '#607D8B',
  'Storage / Troubleshooting': '#795548',
  'Workloads': '#2196F3',
};

// API: 문제 목록
app.get('/api/problems', (req, res) => {
  res.json(getProblems());
});

// API: 문제 내용 (마크다운 → HTML)
app.get('/api/problems/:id', (req, res) => {
  const { id } = req.params;
  const lang = req.query.lang || 'ko';
  const filename = lang === 'en' ? 'problem_en.md' : 'problem.md';
  let problemPath = path.join(PROBLEMS_DIR, id, filename);
  // fallback to Korean if English doesn't exist
  if (!fs.existsSync(problemPath)) {
    problemPath = path.join(PROBLEMS_DIR, id, 'problem.md');
  }
  if (!fs.existsSync(problemPath)) {
    return res.status(404).json({ error: 'Problem not found' });
  }
  const md = fs.readFileSync(problemPath, 'utf-8');
  const html = marked(md);
  // Check if English version exists
  const hasEn = fs.existsSync(path.join(PROBLEMS_DIR, id, 'problem_en.md'));
  res.json({ markdown: md, html, hasEn });
});

// API: 정답 보기
app.get('/api/problems/:id/solution', (req, res) => {
  const { id } = req.params;
  const lang = req.query.lang || 'ko';
  const filename = lang === 'en' ? 'solution_en.md' : 'solution.md';
  let solutionPath = path.join(PROBLEMS_DIR, id, filename);
  if (!fs.existsSync(solutionPath)) {
    solutionPath = path.join(PROBLEMS_DIR, id, 'solution.md');
  }
  if (!fs.existsSync(solutionPath)) {
    return res.status(404).json({ error: 'Solution not found' });
  }
  const md = fs.readFileSync(solutionPath, 'utf-8');
  const html = marked(md);
  res.json({ markdown: md, html });
});

// API: 스크립트 실행 (setup, validate, cleanup)
app.post('/api/problems/:id/:action', (req, res) => {
  const { id, action } = req.params;
  const validActions = ['setup', 'validate', 'cleanup'];
  if (!validActions.includes(action)) {
    return res.status(400).json({ error: 'Invalid action' });
  }

  const scriptPath = path.join(PROBLEMS_DIR, id, `${action}.sh`);
  if (!fs.existsSync(scriptPath)) {
    return res.status(404).json({ error: `${action}.sh not found` });
  }

  // Windows에서 bash 경로를 명시적으로 지정
  const bashPath = process.platform === 'win32' ? 'C:\\Windows\\System32\\bash.exe' : 'bash';
  // WSL bash에서는 Windows 경로를 변환해야 함
  // Git Bash가 있으면 그걸 사용, 없으면 WSL bash 사용
  const gitBash = 'C:\\Program Files\\Git\\bin\\bash.exe';
  const useBash = fs.existsSync(gitBash) ? `"${gitBash}"` : bashPath;

  // 스크립트 경로를 슬래시로 변환 (bash 호환)
  const scriptUnixPath = scriptPath.replace(/\\/g, '/');
  const cwdPath = __dirname.replace(/\\/g, '/');

  const cmd = `${useBash} "${scriptUnixPath}"`;
  exec(cmd, {
    cwd: __dirname,
    timeout: 240000,
    env: { ...process.env, TERM: 'dumb' },
    shell: true
  }, (error, stdout, stderr) => {
    let output = stripAnsi(stdout + (stderr ? '\n' + stderr : ''));
    if (error && error.killed) {
      output += `\n[ERROR] ${action}.sh가 240초 안에 끝나지 않아 중단됐습니다. 출력이 중간에 끊겼을 수 있습니다.`;
    }
    res.json({
      success: !error,
      exitCode: error ? error.code : 0,
      output: output || '(no output)'
    });
  });
});

// 정적 파일 서빙
app.use(express.static(path.join(__dirname, 'public')));

app.listen(PORT, () => {
  console.log(`CKA Practice Lab UI: http://localhost:${PORT}`);
});
