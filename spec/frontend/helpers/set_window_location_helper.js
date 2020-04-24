export default function setWindowLocation(value) {
  Object.defineProperty(window, 'location', {
    writable: true,
    value,
  });
}
