const Todo = require('../models/todo.model');

exports.getTodos = (req, res) => {
    Todo.findAll({}).then((err, todos) => {
        if (err) {
            res.send(err);
        }else{
            res.json(todos);
        }
        
    });
};

exports.createTodo = async (req, res) => {
    const newTodo = Todo.build({
        title: req.body.title,
        label: req.body.label,
        completed: req.body.completed,
        location_id: req.body.locationId
    });
    try {
        const savedTodo = await newTodo.save();
        res.json(savedTodo);
    }catch(err) {
        res.json({message: err});
    }
    
}

exports.deleteTodo = (req, res) => {
    Todo.findByPk(req.params.id)
        .then(todo => todo.destroy().then(() => res.json({success: true})))
        .catch(err => res.status(400).json('Error: ' + err));
}

exports.updateTodo = (req, res) => {
    Todo.findByPk(req.params.id)
        .then(todo => {
            todo.set({
                title: req.body.title,
                label: req.body.label,
                completed: req.body.completed,
                location_id: req.body.locationId
            });

            todo.save()
                .then((todo) => res.json(todo))
                .catch(err => res.status(400).json('Error: ' + err));
        })
        .catch(err => res.status(400).json('Error: ' + err));
}