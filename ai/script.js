const express = require('express');
const fs = require('fs');
const path = require('path');
const multer = require('multer');
const bodyParser = require('body-parser');
const { summarizeText } = require('./openai');

const app = express();
const NOTES_DIR = path.join(__dirname, '../notes');
const upload = multer({ dest: path.join(NOTES_DIR, 'media') });

app.use(bodyParser.json());
app.use(express.static('../frontend'));
app.use('/media', express.static(path.join(NOTES_DIR, 'media')));

// Upload media
app.post('/upload', upload.single('file'), (req, res) => {
    res.json({ path: `/media/${req.file.filename}`, original: req.file.originalname });
});

// Save note
app.post('/notes', (req, res) => {
    const note = req.body;
    const fileName = note.metadata.title.replace(/\s+/g, '_') + '.note';
    fs.writeFileSync(path.join(NOTES_DIR, fileName), JSON.stringify(note, null, 2));
    res.send('Note saved!');
});

// AI suggestion per block
app.post('/ai-suggest', async (req, res) => {
    const { block } = req.body;
    const suggestion = await summarizeText(block.content);
    res.json({ suggestion });
});

app.listen(3000, () => console.log('Server running on http://localhost:3000'));
