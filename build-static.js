// 정적 사이트 빌드 스크립트
// problem.md와 solution.md를 JSON으로 번들링하여 docs/data.json 생성
const fs = require('fs');
const path = require('path');

const PROBLEMS_DIR = path.join(__dirname, 'problems');
const OUTPUT_DIR = path.join(__dirname, 'docs');

const problems = [];

const dirs = fs.readdirSync(PROBLEMS_DIR)
  .filter(d => /^\d{3}$/.test(d))
  .sort();

for (const dir of dirs) {
  const problemPath = path.join(PROBLEMS_DIR, dir, 'problem.md');
  const solutionPath = path.join(PROBLEMS_DIR, dir, 'solution.md');

  let problemMd = '';
  let solutionMd = '';
  let title = `Problem ${dir}`;
  let domain = '';
  let time = '';

  if (fs.existsSync(problemPath)) {
    problemMd = fs.readFileSync(problemPath, 'utf-8');
    const titleMatch = problemMd.match(/^# (.+)/m);
    if (titleMatch) title = titleMatch[1];
    const domainMatch = problemMd.match(/\| 도메인 \| (.+?) \|/);
    if (domainMatch) domain = domainMatch[1].trim();
    const timeMatch = problemMd.match(/\| 예상 소요 시간 \| (.+?) \|/);
    if (timeMatch) time = timeMatch[1].trim();
  }

  if (fs.existsSync(solutionPath)) {
    solutionMd = fs.readFileSync(solutionPath, 'utf-8');
  }

  problems.push({ id: dir, title, domain, time, problem: problemMd, solution: solutionMd });
}

if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR);
fs.writeFileSync(path.join(OUTPUT_DIR, 'data.json'), JSON.stringify(problems));
console.log(`Built ${problems.length} problems → docs/data.json`);
