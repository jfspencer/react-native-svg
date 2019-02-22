#!/usr/bin/env node

const path = require('path');
const fs = require('fs');
const exec = require('child_process').exec;
const execP = command => new Promise(res => exec(command, () => res()));

const assets = 'assets';
const absAssetsPath = path.join(__dirname, '..', 'assets');

const androidDrawable = path.join(__dirname, '..', 'android', 'app', 'src', 'main', 'res', 'drawable');
_cleanFileName = file => file.replace(/\-/g, '_').replace(/ /g, '_');

execP('echo start')
  .then(_ => execP('java -jar assets/Svg2VectorAndroid-1.0.1.jar /assets'))
  .then(_ => _androidConversion(fs.readdirSync(path.join(absAssetsPath, 'ProcessedSVG'))))
  .then(_ => console.log('Ready: Android Studio: Rebuild to see changes'));

_androidConversion = files => {
  files.forEach(file => {
    fs.renameSync(
      path.join(absAssetsPath, 'ProcessedSVG', file),
      path.join(androidDrawable, _cleanFileName(file.replace('_svg', '')))
    );
  });
};
