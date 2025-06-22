const fertilizers = [
  { id: 1, name: 'Organic Compost', price: 50, stock: 100 },
  { id: 2, name: 'NPK Fertilizer', price: 75, stock: 50 },
  { id: 3, name: 'Bio Fertilizer', price: 100, stock: 25 }
];

const fertilizersController = {
  getAllFertilizers: (req, res) => {
    res.json(fertilizers);
  },

  purchaseFertilizer: (req, res) => {
    const { fertilizerId, quantity } = req.body;
    const fertilizer = fertilizers.find(f => f.id === fertilizerId);
    if (!fertilizer) return res.status(404).json({ error: 'Fertilizer not found' });
    if (fertilizer.stock < quantity) return res.status(400).json({ error: 'Insufficient stock' });
    fertilizer.stock -= quantity;
    res.json({ message: 'Fertilizer purchased', fertilizerId, quantity });
  }
};

module.exports = fertilizersController;
