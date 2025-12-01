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
        let value = parseInt(str.substr(1));
        if (direction == Directions.RIGHT) {
            dial += value
        }
        else {
            dial -= value
        }
        dial %= 100;
        if (dial == 0) {
            sum++;
        }
    }
})

console.log(sum)
