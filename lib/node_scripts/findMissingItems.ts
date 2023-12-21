import * as fs from 'fs';
import * as path from 'path';

const itemsFolderPath = '/Users/xyz/Work//DSPWikiRip/recipes'; // Path to the items folder
const jsonFilePath =
  '/Users/xyz/Work/free/dyson-sphere-blueprints/app/javascript/data/gameRecipes.json'; // Path to the JSON file

// Read the contents of the items folder
const itemFolders = fs.readdirSync(itemsFolderPath);

// Read and parse the JSON file
const jsonData = JSON.parse(fs.readFileSync(jsonFilePath, 'utf-8'));

// Extract IDs from folder names
const folderIds = itemFolders.map((folderName) => {
  const [id] = folderName.split('_');
  return id;
});

console.log(folderIds);

// Compare folder IDs with JSON IDs
const missingItems = folderIds.filter((id) => !(id in jsonData));

// Report missing items
console.log('Items missing in JSON:', missingItems);
