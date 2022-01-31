PerfectFunctionSet perfectFunctionSet = new PerfectFunctionSet();
LinearFalloffFunctionSet linearFalloffFunctionSet = new LinearFalloffFunctionSet();
EvenDiffuseFunctionSet evenDiffuseFunctionSet = new EvenDiffuseFunctionSet();
DiffuseFunctionSet diffuseFunctionSet = new DiffuseFunctionSet();
BlendFunctionSet blendFunctionSet = new BlendFunctionSet(diffuseFunctionSet, linearFalloffFunctionSet);
DiffuseSpecularFalloffFunctionSet diffuseSpecularFalloffFunctionSet = new DiffuseSpecularFalloffFunctionSet();

FunctionSet functionSet = diffuseSpecularFalloffFunctionSet;

Chart polarDistributionChart = new Chart();
Chart intensityDistributionChart = new Chart();
Chart intensityIntegralChart = new Chart();
Chart probabilityDistributionChart = new Chart();

int[] counts = new int[180];
int chartCount = 4;

color incidentColor = color(255, 0, 0);
color chartColor = color(0, 255, 0);
color resultColor = color(0, 0, 255);

void setup()
{
    size(400, 800);

    PVector chartSize = new PVector(width - 40, (height / chartCount) - 40);

    polarDistributionChart.position.x = 20;
    polarDistributionChart.position.y = 20 + 0;
    polarDistributionChart.size = chartSize.copy();
    polarDistributionChart.minimum.x = -90.0;
    polarDistributionChart.maximum.x = 90.0;
    polarDistributionChart.minimum.y = 0.0;
    polarDistributionChart.maximum.y = 1.0;
    polarDistributionChart.function = new IntensityDistrubtionRef(functionSet);
    polarDistributionChart.polar = true;

    intensityDistributionChart.position.x = 20;
    intensityDistributionChart.position.y = 20 + 200;
    intensityDistributionChart.size = chartSize.copy();
    intensityDistributionChart.minimum.x = -90.0;
    intensityDistributionChart.maximum.x = 90.0;
    intensityDistributionChart.minimum.y = 0.0;
    intensityDistributionChart.maximum.y = 1.0;
    intensityDistributionChart.function = new IntensityDistrubtionRef(functionSet);

    intensityIntegralChart.position.x = 20;
    intensityIntegralChart.position.y = 20 + 400;
    intensityIntegralChart.size = chartSize.copy();
    intensityIntegralChart.minimum.x = -90.0;
    intensityIntegralChart.maximum.x = 90.0;
    intensityIntegralChart.minimum.y = 0.0;
    intensityIntegralChart.maximum.y = 1.0;
    intensityIntegralChart.function = new TrueIntegralRef(functionSet);

    probabilityDistributionChart.position.x = 20;
    probabilityDistributionChart.position.y = 20 + 600;
    probabilityDistributionChart.size = chartSize.copy();
    probabilityDistributionChart.minimum.x = 0.0;
    probabilityDistributionChart.maximum.x = 1.0;
    probabilityDistributionChart.minimum.y = -90.0;
    probabilityDistributionChart.maximum.y = 90.0;
    probabilityDistributionChart.function = new ProbabilityDistributionRef(functionSet);
}

void draw()
{
    functionSet.setInputAngle(sin(((frameCount % 1440) / 1440.0) * 2 * PI) * 60);
    functionSet.setKnee(0.001 + ((sin(((frameCount % 240) / 240.0) * 2 * PI) + 1.0) / 2.0) * 60);
    //functionSet.setKnee(10);

    blendFunctionSet.setBlend((cos(((frameCount % 2880) / 2880.0) * 2 * PI) + 1.0) / 2.0);

    diffuseSpecularFalloffFunctionSet.setSpecularStrength(1.0);
    diffuseSpecularFalloffFunctionSet.setDiffuseStrength(1.0);
    //diffuseSpecularFalloffFunctionSet.setSigma(0.2 + ((cos(((frameCount % 2880) / 2880.0) * 2 * PI) + 1.0) / 2.0) * 0.8);
    diffuseSpecularFalloffFunctionSet.setSigma(0.2);

    background(0);
    strokeWeight(2);
    stroke(100);
    for (int i = 0; i < chartCount - 1; ++i)
    {
        line(0, height * ((i + 1.0) / chartCount), width, height * ((i + 1.0) / chartCount));
    }

    for (int i = 0; i < counts.length; ++i)
    {
        counts[i] = 0;
    }

    for (int i = 0; i < 2000; ++i)
    {
        int index = round(probabilityDistributionChart.function.call(random(1.0))) + 90;
        if (index >= 0 && index < 180)
        {
            counts[index]++;
        }
    }

    float maxCount = 0.0;
    for (int count : counts)
    {
        maxCount = max(maxCount, count);
    }

    PVector resultSize = intensityDistributionChart.size;

    PVector cartesianPosition = intensityDistributionChart.position;
    float cartesianBaseX = cartesianPosition.x;
    float cartesianBaseY = cartesianPosition.y + resultSize.y;
    float cartesianTopY = cartesianPosition.y;

    PVector polarPosition = polarDistributionChart.position;
    float polarBaseX = polarPosition.x + (resultSize.x / 2.0);
    float polarBaseY = polarPosition.y + resultSize.y;

    strokeWeight(1);
    stroke(resultColor);
    for (int i = 0; i < counts.length; ++i)
    {
        float xNorm = i / (counts.length - 1.0);
        float yNorm = counts[i] / maxCount;

        float cartesianX = cartesianBaseX + (xNorm * resultSize.x);
        float cartesianY = cartesianBaseY - (yNorm * resultSize.y);
        line(cartesianX, cartesianBaseY, cartesianX, cartesianY);

        PVector polarCoordinate = getPolarCoordinate(-90 + (xNorm * 180), yNorm * resultSize.y);
        float polarX = polarBaseX + polarCoordinate.x;
        float polarY = polarBaseY - polarCoordinate.y;
        line(polarBaseX, polarBaseY, polarX, polarY);
    }

    float incidentAngle = -functionSet.inputAngle;
    float cartesianIncidentX = cartesianBaseX + ((incidentAngle + 90) / 180.0) * resultSize.x;
    PVector polarIncident = getPolarCoordinate(incidentAngle, resultSize.y);
    float polarIncidentX = polarBaseX + polarIncident.x;
    float polarIncidentY = polarBaseY - polarIncident.y;

    strokeWeight(1);
    stroke(incidentColor);
    line(cartesianIncidentX, cartesianBaseY, cartesianIncidentX, cartesianTopY);
    line(polarBaseX, polarBaseY, polarIncidentX, polarIncidentY);

    polarDistributionChart.draw();
    intensityDistributionChart.draw();
    intensityIntegralChart.draw();
    probabilityDistributionChart.draw();
}
