const input = Bun.file("input");
const input_text = await input.text();
const Directions = {
    LEFT: "L",
    RIGHT: "R",
}
var sum = 0;
var dial = 50;

input_text.split("\n").forEach((str) => {
    if (str) {
        let direction = str.at(0);
        console.log(str)
        let value = parseInt(str.substr(1));
        let zero = (dial == 0)
        if (direction == Directions.RIGHT) {
            dial += value
        }
        else {
            dial -= value
        }
        sum += Math.abs(Math.trunc(dial / 100));
        sum += (!zero && dial <= 0)
        console.log(sum)
        dial %= 100;
        if (dial < 0) dial += 100
        console.log(dial)
    }
})

console.log(sum)
