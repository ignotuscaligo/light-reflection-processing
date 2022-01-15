class FunctionSet
{
    public float inputAngle = 0.0;
    public float knee = 0.0;

    protected float minAngle;
    protected float maxAngle;
    protected float angleRange;

    public void setInputAngle(float inputAngle)
    {
        this.inputAngle = inputAngle;
        minAngle = inputAngle - knee;
        maxAngle = inputAngle + knee;
        angleRange = maxAngle - minAngle;
    }

    public void setKnee(float knee)
    {
        this.knee = knee;
        minAngle = inputAngle - knee;
        maxAngle = inputAngle + knee;
        angleRange = maxAngle - minAngle;
    }

    // Given 0 to 1, interpolate between minAngle and maxAngle
    protected float interpolatedAngle(float input)
    {
        return minAngle + (angleRange * input);
    }

    // Given -90 to 90 degrees, returns the relative intensity
    public float intensityDistribution(float angle)
    {
        return 0.0;
    }

    // Integral of the intensity distribution, returns -90 to 90 degrees
    // Represents an inverse measure of how often a given angle would be selected
    public float intensityIntegral(float input)
    {
        return 0.0;
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

class LinearFalloffFunctionSet extends FunctionSet
{
    public float intensityDistribution(float angle)
    {
        return 1.0 - min(abs(angle - inputAngle) / knee, 1.0);
    }

    public float intensityIntegral(float input)
    {
        float integral = 0.0;

        if (input <= 0.5)
        {
            float inputPortion = input * 2.0;
            integral = knee * inputPortion * inputPortion;
        }
        else
        {
            float inputPortion = 2.0 - (2.0 * input);
            integral = knee * (2.0 - (inputPortion * inputPortion));
        }

        return minAngle + integral;
    }

    public float probabilityDistribution(float input)
    {
        float targetAngle = interpolatedAngle(input);
        float derivedIntegral = targetAngle - minAngle;
        float derivedInput = 0.0;

        if (input <= 0.5)
        {
            derivedInput = sqrt(derivedIntegral / knee) / 2.0;
        }
        else
        {
            derivedInput = 1.0 - (sqrt(-((derivedIntegral - (2 * knee)) / knee)) / 2.0);
        }

        return interpolatedAngle(derivedInput);
    }
}

class PerfectFunctionSet extends FunctionSet
{
    public float intensityDistribution(float angle)
    {
        if (abs(angle - inputAngle) <= knee)
        {
            return 1.0;
        }
        else
        {
            return 0.0;
        }
    }

    public float intensityIntegral(float input)
    {
        if (knee == 0.0)
        {
            return inputAngle;
        }
        else
        {
            return (inputAngle - knee) + (knee * input * 2.0);
        }
    }

    public float probabilityDistribution(float input)
    {
        if (knee == 0.0)
        {
            return inputAngle;
        }
        else
        {
            float derivedIntegral = interpolatedAngle(input);
            float derivedInput = (derivedIntegral - inputAngle + knee) / (2.0 * knee);
            return interpolatedAngle(derivedInput);
        }
    }
}

class EvenDiffuseFunctionSet extends FunctionSet
{
    public float intensityDistribution(float angle)
    {
        return 1.0;
    }

    public float intensityIntegral(float input)
    {
        return -90 + (180 * input);
    }

    public float probabilityDistribution(float input)
    {
        return -90 + (180 * input);
    }
}

class DiffuseFunctionSet extends FunctionSet
{
    public float intensityDistribution(float angle)
    {
        return cos(radians(angle));
    }

    public float intensityIntegral(float input)
    {
        return sin(radians(-90 + (180 * input))) * 90;
    }

    public float probabilityDistribution(float input)
    {
        float derivedIntegral = -90 + (180 * input);
        float derivedInput = (degrees(asin(derivedIntegral / 90.0)) + 90.0) / 180.0;
        return -90 + (180 * derivedInput);
    }
}


class BlendFunctionSet extends FunctionSet
{
    public FunctionSet setA;
    public FunctionSet setB;
    public float blend;

    BlendFunctionSet(FunctionSet setA, FunctionSet setB)
    {
        super();
        this.setA = setA;
        this.setB = setB;
        this.blend = 0.5;
    }

    public void setInputAngle(float inputAngle)
    {
        setA.setInputAngle(inputAngle);
        setB.setInputAngle(inputAngle);
    }

    public void setKnee(float knee)
    {
        setA.setKnee(knee);
        setB.setKnee(knee);
    }

    public void setBlend(float blend)
    {
        this.blend = blend;
    }

     public float intensityDistribution(float angle)
    {
        return lerp(
            setA.intensityDistribution(angle),
            setB.intensityDistribution(angle),
            blend
        );
    }

    public float intensityIntegral(float input)
    {
        return lerp(
            setA.intensityIntegral(input),
            setB.intensityIntegral(input),
            blend
        );
    }

    public float probabilityDistribution(float input)
    {
        return lerp(
            setA.probabilityDistribution(input),
            setB.probabilityDistribution(input),
            blend
        );
    }
}
