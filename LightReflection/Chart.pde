class Chart
{
    PVector position;
    PVector size;
    PVector minimum;
    PVector maximum;
    FunctionRef function;
    boolean polar;

    Chart()
    {
        position = new PVector();
        size = new PVector();
        minimum = new PVector();
        maximum = new PVector();
        function = null;
        polar = false;
    }

    void draw()
    {
        if (function != null)
        {
            int xCount = round(size.x);
            for (int i = 0; i < xCount; ++i)
            {
                float xNorm = i / (xCount - 1.0);
                float input = minimum.x + ((maximum.x - minimum.x) * xNorm);
                float output = function.call(input);
                float yNorm = (output - minimum.y) / (maximum.y - minimum.y);

                if (yNorm < 0.0 || yNorm > 1.0)
                {
                    continue;
                }

                float x = xNorm * size.x;
                float y = yNorm * size.y;

                if (polar)
                {
                    PVector polarCoordinate = getPolarCoordinate(input, y);
                    x = (size.x / 2.0) + polarCoordinate.x;
                    y = polarCoordinate.y;
                }

                stroke(chartColor);
                point(position.x + x, (position.y + size.y) - y);
            }
        }

        strokeWeight(1);
        stroke(255);
        line(position.x + (size.x / 2.0), position.y, position.x + (size.x / 2.0), position.y + size.y);
        line(position.x, position.y + size.y, position.x + size.x, position.y + size.y);
    }
}
