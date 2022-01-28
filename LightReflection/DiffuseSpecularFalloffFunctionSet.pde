class DiffuseSpecularFalloffFunctionSet extends FunctionSet
{
    public float diffuseStrength = 0.0;
    public float specularStrength = 1.0;
    public float standardDeviation = 0.2;

    protected float peakValue = 0.0;

    DiffuseSpecularFalloffFunctionSet()
    {
        super();
        updateValues();
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

    public void setStandardDeviation(float value)
    {
        standardDeviation = min(max(0.0, value), 1.0);
        updateValues();
    }

    private void updateValues()
    {
        peakValue = diffuseStrength + specularStrength;
    }

    // Given -90 to 90 degrees, returns the relative intensity
    public float intensityDistribution(float angle)
    {
        // specular start = inputAngle - knee
        // specular end = inputAngle + knee
        // angle = 30
        // input angle = 45
        // knee = 10
        // distance = (30 - 45) + 10 = -5
        // position = clamp(0, distance, knee * 2) = clamp(0, -5, 20) = 0
        // angle = 50
        // input angle = 45
        // knee = 10
        // distance = (50 - 45) + 10 = 15
        // position = clamp(0, distance, knee * 2) = clamp(0, 15, 20) = 15
        // float distance = angle - inputAngle;
        // float offsetDistance = distance + knee;
        // float clampedDistance = min(max(0.0, offsetDistance), angleRange);
        // float position = clampedDistance / angleRange;
        // float specular = sin(position * PI) * specularStrength;
        // return (diffuseStrength + specular);
        float mu = inputAngle / 90.0;
        float x = angle / 90.0;
        float sigma = standardDeviation;
        float a = (x - mu) / sigma;
        float b = pow(exp(1.0), -0.5 * (a * a));
        float c = 1.0 / (sigma * sqrt(2 * PI));

        return b; // * c;
    }
    
    // Given -90 to 90 degrees, return the integral of intensity
    public float trueIntegral(float input)
    {
        float normalizedPosition = (input + 90.0) / 180.0;
        float diffuseIntegral = normalizedPosition * diffuseStrength;
        float peakDiffuseIntegral = diffuseStrength;
        
        
        // d = i - I
        // o = d + k
        // p = o / 2k
        // s = sin(p * PI) * S
        // s = sin(x * PI) * y
        
        // si = -((y * cos(x * PI)) / PI)
        // si = -((S * cos(p * PI)) / PI)
        // si = -((specularStrength * cos(position * PI)) / PI)
        
        
        
        float distance = input - inputAngle;
        float offsetDistance = distance + knee;
        float clampedDistance = min(max(0.0, offsetDistance), angleRange);
        float position = clampedDistance / angleRange;
        //float specularIntegral = (-((specularStrength * (cos(position * PI) - 1.0)) / PI)) * (knee / 90.0);
        //float peakSpecularIntegral = (-((specularStrength * -2.0) / PI)) * (knee / 90.0);
        
        
        
        // ((-((specularStrength * (cos(position * PI) - 1.0)) / PI)) * (knee / 90.0)) / ((-((specularStrength * -2.0) / PI)) * (knee / 90.0))
        // ((-((S * (cos(p * PI) - 1.0)) / PI)) * (k / 90.0)) / ((-((S * -2.0) / PI)) * (k / 90.0))
        // ni = ((-((z * (cos(x * PI) - 1.0)) / PI)) * (y / 90.0)) / ((-((z * -2.0) / PI)) * (y / 90.0))
        // ni = ((-((z * (cos(x * PI) - 1.0)) / PI))) / ((-((z * -2.0) / PI)))
        // ni = ((-((z * (cos(x * PI) - 1.0))))) / ((-((z * -2.0))))
        // ni = -((z * (cos(x * PI) - 1.0))) / -((z * -2.0))
        // ni = -(((cos(x * PI) - 1.0))) / -((-2.0))
        // ni = -(cos(x * PI) - 1.0) / -(-2.0)
        // ni = -(cos(x * PI) - 1.0) / 2.0
        // ni = -0.5 * (cos(x * PI) - 1.0)
        
        
        // x = 0.5
        // y = 30.0
        // z = 1.0
        // ni = ((-((z * (cos(x * PI) - 1.0)) / PI)) * (y / 90.0)) / ((-((z * -2.0) / PI)) * (y / 90.0))
        // ni = ((-((1.0 * (cos(0.5 * PI) - 1.0)) / PI)) * (30.0 / 90.0)) / ((-((1.0 * -2.0) / PI)) * (30.0 / 90.0))
        // ni = ((-((1.0 * (0.0 - 1.0)) / PI)) * (30.0 / 90.0)) / ((-((1.0 * -2.0) / PI)) * (30.0 / 90.0))
        // ni = ((-((1.0 * (-1.0)) / PI)) * (30.0 / 90.0)) / ((-((1.0 * -2.0) / PI)) * (30.0 / 90.0))
        // ni = ((-((1.0 * (-1.0)) / PI)) * (30.0 / 90.0)) / ((-((-2.0) / PI)) * (30.0 / 90.0))
        // ni = ((-((1.0 * (-1.0)) / PI)) * (30.0 / 90.0)) / ((-(-0.6366)) * (30.0 / 90.0))
        // ni = ((-((1.0 * (-1.0)) / PI)) * (0.3333)) / ((-(-0.6366)) * (0.3333))
        // ni = ((-((1.0 * (-1.0)) / PI)) * (0.3333)) / ((0.6366) * (0.3333))
        // ni = ((-((1.0 * (-1.0)) / PI)) * (0.3333)) / (0.2121)
        // ni = ((-((-1.0) / PI)) * (0.3333)) / (0.2121)
        // ni = ((-(-0.3183)) * (0.3333)) / (0.2121)
        // ni = ((0.3183) * (0.3333)) / (0.2121)
        // ni = (0.1060) / (0.2121)
        // ni = 0.4997
        
        // x = 0.5
        // y = 30.0
        // z = 1.0
        // ni = -0.5 * (cos(x * PI) - 1.0)
        // ni = -0.5 * (cos(0.5 * PI) - 1.0)
        // ni = -0.5 * (0.0 - 1.0)
        // ni = -0.5 * -1.0
        // ni = 0.5
        
        //float peakIntegral = peakDiffuseIntegral + peakSpecularIntegral;
        //return (diffuseIntegral + specularIntegral) / peakIntegral;
        
        float normalizedSpecularIntegral = (-0.5 * (cos(position * PI) - 1.0)) * (knee / 90.0) * specularStrength;
        
        return (diffuseIntegral + normalizedSpecularIntegral) / (diffuseStrength + ((knee / 90.0) * specularStrength));
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
        return 0.0;
    }
}
