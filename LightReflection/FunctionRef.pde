class FunctionRef
{
    public FunctionSet functionSet;

    FunctionRef(FunctionSet functionSet)
    {
        this.functionSet = functionSet;
    }

    public float call(float input)
    {
        return 0.0;
    }
}

class IntensityDistrubtionRef extends FunctionRef
{
    IntensityDistrubtionRef(FunctionSet functionSet)
    {
        super(functionSet);
    }

    public float call(float angle)
    {
        return functionSet.intensityDistribution(angle);
    }
}

class IntensityIntegralRef extends FunctionRef
{
    IntensityIntegralRef(FunctionSet functionSet)
    {
        super(functionSet);
    }

    public float call(float input)
    {
        return functionSet.intensityIntegral(input);
    }
}

class ProbabilityDistributionRef extends FunctionRef
{
    ProbabilityDistributionRef(FunctionSet functionSet)
    {
        super(functionSet);
    }

    public float call(float input)
    {
        return functionSet.probabilityDistribution(input);
    }
}
