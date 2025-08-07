const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();

app.use(cors({
  origin: 'https://piloto-mantenimiento-vehiculo.web.app',
}));

app.use(express.json());

// ✅ Manejo del preflight OPTIONS
app.options('/proxy', (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', 'https://piloto-mantenimiento-vehiculo.web.app');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.sendStatus(204);
});

// ✅ Proxy principal
app.post('/proxy', async (req, res) => {
  try {
    const { endpoint, data } = req.body;

    const response = await axios.post(
      `http://jonathanvs-001-site1.mtempurl.com${endpoint}`,
      data,
      {
        headers: {
          'Content-Type': 'application/json',
        }
      }
    );

    res.setHeader('Access-Control-Allow-Origin', 'https://piloto-mantenimiento-vehiculo.web.app');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    res.status(response.status).json(response.data);
  } catch (error) {
    console.error('Error en el proxy:', error.message);

    res.setHeader('Access-Control-Allow-Origin', 'https://piloto-mantenimiento-vehiculo.web.app');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    res.status(500).json({ error: 'Error en el proxy', details: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Proxy corriendo en puerto ${PORT}`));
