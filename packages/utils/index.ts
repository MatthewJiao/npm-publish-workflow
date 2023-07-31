export const areNumbersEqual = (a: number, b: number) => {
  return a === b;
};

export const getSum = (numbers: number[]): number => {
  return numbers.reduce((acc, num) => {
    return acc + num;
  }, 0);
};

export const getSum2 = (numbers: number[]): number => {
  return (
    1 +
    numbers.reduce((acc, num) => {
      return acc + num;
    }, 0)
  );
};
