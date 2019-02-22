//This file generates @components/icon-names.js
//IMPORTANT This script depends on the ruby gem xcodeproj -> https://github.com/CocoaPods/Xcodeproj
//sudo gem install xcodeproj if its missing

const path = require('path');
const { Future, of } = require('fluture');
const fs = require('fs');
const xml = require('xml2js').Parser;
const { execSync } = require('child_process');

const GENERATED_NOTE = `//THIS IS A GENERATED FILE. USE : yarn generateIcons TO UPDATE THIS FILE\n`;

const assets = path.join(__dirname, 'assets');

_cleanFileName = file =>
  file
    .replace(/\-/g, '_')
    .replace(/ /g, '_')
    .replace('icon_', '');

const _convert = (assetsPath, files) => {
  //convert each file name into a future
  return files.reduce((accum, file) => {
    return accum.chain(string => {
      return Future((rej, res) => {
        if (file.includes('.svg') && file !== 'ProcessedSVG') {
          const cleanFile = _cleanFileName(file);
          fs.renameSync(path.join(assetsPath, file), path.join(assetsPath, cleanFile));
          const svgData = fs.readFileSync(path.join(assetsPath, cleanFile));
          const parser = new xml();
          parser.parseString(svgData, (err, result) => {
            if (err) {
              console.error('failed to parse SVG: ', svgData);
              console.error(err);
              process.exit(7);
            }
            const [w, h, aspectW, aspectH] = result.svg.$.viewBox.split(' ');
            const NAME = cleanFile.replace('.svg', '').toUpperCase();
            const name = cleanFile.replace('.svg', '').toLowerCase();
            res(string + `  ${NAME}: '${name}/${aspectW}/${aspectH}',\n`);
          });
        } else res(string);
      });
    });
  }, of(''));
};

of(assets => {
  const assetLines = assets.slice(0, -2) + '\n';
  return `${GENERATED_NOTE}
export const ICONS = {
${assetLines}};
`;
})
  .ap(_convert(assets, fs.readdirSync(assets)))
  .fork(console.error, out => {
    fs.writeFileSync(path.join(__dirname, '..', 'src', 'constants', 'icon-names.js'), out);

    // run ruby script to update xcode
    // rebuilds Xcode SVG group based on state of assets
    execSync('ruby assets/updateAssetsXcode.rb');

    //run sed filter to clean up pbxproj old file artifact lines
    const pattern = `'/BuildFile in Sources /d'`;
    const pattern2 = `'/BuildFile in Resources /d'`;
    const xcodeProj = 'ios/Example.xcodeproj/project.pbxproj';
    const xcodeProjNew = 'ios/Example.xcodeproj/project.new.pbxproj';
    execSync(`sed ${pattern} ${xcodeProj} > ${xcodeProjNew} && rm -rf ${xcodeProj}`);
    fs.renameSync(
      path.join(__dirname, '..', 'ios', 'Example.xcodeproj', 'project.new.pbxproj'),
      path.join(__dirname, '..', 'ios', 'Example.xcodeproj', 'project.pbxproj')
    );

    execSync(`sed ${pattern2} ${xcodeProj} > ${xcodeProjNew} && rm -rf ${xcodeProj}`);
    fs.renameSync(
      path.join(__dirname, '..', 'ios', 'Example.xcodeproj', 'project.new.pbxproj'),
      path.join(__dirname, '..', 'ios', 'Example.xcodeproj', 'project.pbxproj')
    );
    console.log('Ready: Xcode: Rebuild to see changes');
  });
