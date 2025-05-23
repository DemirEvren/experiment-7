const Sequelize = require('sequelize');
const sequelize = require('./../db');

const Todo = sequelize.define('todo', {
    title: {
        type: Sequelize.STRING,
        allowNull: false
    },
    label: {
        type: Sequelize.STRING,
        allowNull: false
    },
    completed: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false
    },
    _id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true
    },
    location_id: { // ✅ NEW FIELD
        type: Sequelize.STRING,
        allowNull: true // it can be null if user doesn't select a location
    }
});

sequelize.sync().then(() => 
    console.log('Todo table created successfully')
);

module.exports = Todo;
