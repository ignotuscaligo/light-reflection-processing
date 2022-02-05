public class CauchyDistributionFunctionSet extends FunctionSet
{
    public float sigma = 0.2;

    private float mu = 0.0;
    private float sigmaPi = 0.0;

    private float intensityMin = 0.0;
    private float intensityMax = 0.0;
    private float intensityRange = 0.0;

    private float integralMin = 0.0;
    private float integralMax = 0.0;
    private float integralRange = 0.0;

    CauchyDistributionFunctionSet()
    {
        super();
        updateValues();
    }

    public void setInputAngle(float inputAngle)
    {
        super.setInputAngle(inputAngle);
        updateValues();
    }

    public void setSigma(float value)
    {
        sigma = min(max(0.0, value), 2.0);
        updateValues();
    }

    private void updateValues()
    {
        mu = inputAngle / 90.0;
        sigmaPi = PI * sigma;
        intensityMin = cauchyDistribution(180.0, 0.0);
        intensityMax = 1.0 / sigmaPi;
        intensityRange = intensityMax - intensityMin;
        integralMin = cauchyIntegral(-90.0, mu);
        integralMax = cauchyIntegral(90.0, mu);
        integralRange = integralMax - integralMin;
    }

    private float cauchyDistribution(float angle, float offset)
    {
        // Cauchy PDF
        float x = angle / 90.0;
        return 1.0 / (sigmaPi * (1.0 + pow((x - offset) / sigma, 2.0)));
    }

    // Given -90 to 90 degrees, returns the relative intensity
    public float intensityDistribution(float angle)
    {
        return (cauchyDistribution(angle, mu) - intensityMin) / intensityRange;
    }

    private float cauchyIntegral(float angle, float offset)
    {
        float x = angle / 90.0;
        return atan((x - offset) / sigma) / PI;
    }

    // Given -90 to 90 degrees, return the integral of intensity
    public float trueIntegral(float angle)
    {
        return (cauchyIntegral(angle, mu) - integralMin) / integralRange;
    }

    private float cauchyInverseIntegral(float input)
    {
        float inverseIntegral = sigma * tan(input * PI) + mu;
        return -90.0 + (inverseIntegral * 180.0);
    }

    // Above integral solved for the input, then remapped to -90 to 90 degrees
    // Represents the probability distribution of a given angle being selected
    // Given a random number between 0 and 1, the distribution of values should match
    // the intensityDistribution.
    public float probabilityDistribution(float input)
    {
        float inverseIntegral = sigma * tan(((input * integralRange) + integralMin) * PI) + mu;
        return inverseIntegral * 90.0;
    }
}
