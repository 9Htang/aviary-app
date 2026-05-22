const fs = require('fs');
let t = fs.readFileSync('C:/Users/Cwb/.openclaw/workspace/aviary/server.js', 'utf-8');

// Fix 1: getGrowthStage date calculation (UTC-safe)
t = t.replace(
  "const ageDays = Math.floor((new Date() - new Date(hatchDate)) / (1000 * 60 * 60 * 24));",
  "const ageDays = Math.floor((Date.now() - new Date(hatchDate).getTime()) / (1000 * 60 * 60 * 24));"
);

// Fix 2: isBreedable date calculation
t = t.replace(
  "const ageDays = Math.floor((new Date() - new Date(hatchDate)) / (1000 * 60 * 60 * 24));",
  "const ageDays = Math.floor((Date.now() - new Date(hatchDate).getTime()) / (1000 * 60 * 60 * 24));"
);

fs.writeFileSync('C:/Users/Cwb/.openclaw/workspace/aviary/server.js', t, 'utf-8');
console.log('Fixed date calculations');
