const express = require('express')
const app = express()

const port = 3000
app.get('/', (req, res) => res.send(
    `
        <h1>Application successfully migrated to AWS!</h1>
        <p>Done by Nian Kai @ Govtech TAP 2023</p>
    `
))
app.listen(port, () => console.log(`Application is listening on port ${port}!`))