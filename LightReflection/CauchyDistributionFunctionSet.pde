public class CauchyDistributionFunctionSet extends FunctionSet
{
    public float diffuseStrength = 0.0;
    public float specularStrength = 1.0;
    public float sigma = 0.2;

    protected float peakValue = 0.0;

    private float mu = 0.0;
    private float combinedStrength = 0.0;
    private float sigmaPi = 0.0;

    private float intensityMin = 0.0;
    private float intensityMax = 0.0;
    private float intensityRange = 0.0;

    private float integralMin = 0.0;
    private float integralMax = 0.0;
    private float integralRange = 0.0;

    private float inverseIntegralMin = 0.0;
    private float inverseIntegralMax = 0.0;
    private float inverseIntegralRange = 0.0;

    CauchyDistributionFunctionSet()
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
        sigmaPi = PI * sigma;
        intensityMin = cauchyDistribution(180.0, 0.0);
        intensityMax = 1.0 / sigmaPi;
        intensityRange = intensityMax - intensityMin;
        integralMin = cauchyIntegral(-90.0, mu);
        integralMax = cauchyIntegral(90.0, mu);
        integralRange = integralMax - integralMin;
        inverseIntegralMin = cauchyInverseIntegral(0);
        inverseIntegralMax = cauchyInverseIntegral(1);
        inverseIntegralRange = inverseIntegralMax - inverseIntegralMin;

        float value0 = sigma * tan(((0.0 * integralRange) + integralMin) * PI) + mu;
        float value1 = sigma * tan(((0.5 * integralRange) + integralMin) * PI) + mu;
        float value2 = sigma * tan(((1.0 * integralRange) + integralMin) * PI) + mu;

        print("value0: ");
        println(value0);
        print("value1: ");
        println(value1);
        print("value2: ");
        println(value2);
    }

    private float cauchyDistribution(float angle, float offset)
    {
        // Cauchy PDF
        float x = angle / 90.0;
        return 1.0 / (sigmaPi * (1.0 + pow((x - offset) / sigma, 2.0)));
    }

    private float specularIntensity(float angle)
    {
        float specular = (cauchyDistribution(angle, mu) - intensityMin) / intensityRange;
        return specular * specularStrength;
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

    private float cauchyIntegral(float angle, float offset)
    {
        float x = angle / 90.0;
        return atan((x - offset) / sigma) / PI;
    }

    private float specularIntegral(float angle)
    {
        float specularIntegral = (cauchyIntegral(angle, mu) - integralMin) / integralRange;

        return specularIntegral * specularStrength;
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
        float diffuseInverse = -90.0 + (input * 180.0);
        if (diffuseStrength > 0.0)
        {
            diffuseInverse = degrees(asin(((2.0 * input) / diffuseStrength) - 1.0));
        }

        float inverseIntegral = sigma * tan(((input * integralRange) + integralMin) * PI) + mu;
        float specularInverse = inverseIntegral * 90.0;

        return ((diffuseInverse * diffuseStrength) + (specularInverse * specularStrength)) / combinedStrength;
    }
}
