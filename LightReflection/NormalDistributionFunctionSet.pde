class NormalDistributionFunctionSet extends FunctionSet
{
    public float diffuseStrength = 0.0;
    public float specularStrength = 1.0;
    public float sigma = 0.2;

    protected float peakValue = 0.0;

    private float mu = 0.0;
    private float combinedStrength = 0.0;

    NormalDistributionFunctionSet()
    {
        super();
        updateValues();
    }

    public void setInputAngle(float inputAngle)
    {
        super.setInputAngle(inputAngle);
        mu = inputAngle / 90.0;
    }

    public void setDiffuseStrength(float value)
    {
        diffuseStrength = min(max(0.0, value), 1.0);
        updateValues();
    }

    public void setSpecularStrength(float value)
    {
        specularStrength = min(max(0.0, value), 1.0);
        updateValues();
    }

    public void setSigma(float value)
    {
        sigma = min(max(0.0, value), 1.0);
        updateValues();
    }

    private void updateValues()
    {
        peakValue = diffuseStrength + specularStrength;
        combinedStrength = diffuseStrength + specularStrength;
    }

    private float specularIntensity(float angle)
    {
        float x = angle / 90.0;
        float a = (x - mu) / sigma;
        float b = pow(exp(1.0), -0.5 * (a * a));

        return b * specularStrength;
    }

    private float diffuseIntensity(float angle)
    {
        return cos(radians(angle)) * diffuseStrength;
    }

    // Given -90 to 90 degrees, returns the relative intensity
    public float intensityDistribution(float angle)
    {
        if (combinedStrength == 0.0)
        {
            return 0.0;
        }
        else
        {
            return (specularIntensity(angle) + diffuseIntensity(angle)) / combinedStrength;
        }
    }

    private float specularIntegral(float angle)
    {
        float x = angle / 90.0;
        float a = (x - mu) / sigma;
        float b = (float)erf(a / sqrt(2.0));

        return ((1.0 + b) / 2.0) * specularStrength;
    }

    private float diffuseIntegral(float angle)
    {
        return ((1.0 + sin(radians(angle))) / 2.0) * diffuseStrength;
    }

    // Given -90 to 90 degrees, return the integral of intensity
    public float trueIntegral(float angle)
    {
        if (combinedStrength == 0.0)
        {
            return 0.0;
        }
        else
        {
            return (specularIntegral(angle) + diffuseIntegral(angle)) / combinedStrength;
        }
    }

    // Integral of the intensity distribution, returns -90 to 90 degrees
    // Represents an inverse measure of how often a given angle would be selected
    public float intensityIntegral(float input)
    {
        float angle = -90.0 + (input * 180.0);
        float distance = angle - inputAngle;
        float offsetDistance = distance + knee;
        float clampedDistance = min(max(0.0, offsetDistance), angleRange);
        float position = clampedDistance / angleRange;
        float specularIntegral = cos(position * PI) * specularStrength;
        float diffuseIntegral = (-90 + (180 * input)) * diffuseStrength;
        return (diffuseIntegral + specularIntegral) / peakValue;
    }

    // Above integral solved for the input, then remapped to -90 to 90 degrees
    // Represents the probability distribution of a given angle being selected
    // Given a random number between 0 and 1, the distribution of values should match
    // the intensityDistribution.
    public float probabilityDistribution(float input)
    {
        // float x = angle / 90.0;
        // float a = (x - mu) / sigma;
        // float b = (float)erf(a / sqrt(2.0));

        // return ((1.0 + b) / 2.0) * specularStrength;


        // ((1.0 + sin(radians(angle))) / 2.0) * diffuseStrength

        float diffuseInverse = degrees(asin(((2.0 * input) / diffuseStrength) - 1.0));

        float specularInverseNormalized = sigma * sqrt(2.0) * (float)erfinv(((2.0 * input) / specularStrength) - 1.0) + mu;
        float specularInverse = -90.0 + (specularInverseNormalized * 180.0);

        return ((diffuseInverse * diffuseStrength) + (specularInverse * specularStrength)) / combinedStrength;
    }
}
