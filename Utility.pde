PVector getPolarCoordinate(float angle, float radius)
{
  float rho = radius;
  float theta = radians(-angle + 90);
  return new PVector(cos(theta) * rho, sin(theta) * rho);
}
