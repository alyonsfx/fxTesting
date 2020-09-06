using System;
using TMPro;
using UnityEngine;
using Random = UnityEngine.Random;

[RequireComponent(typeof(LineRenderer))]
public class Beam : MonoBehaviour
{
    [SerializeField] private float _lifetime;
    [SerializeField] private Gradient _colorOverLifetime;
    [SerializeField] private Gradient _colorOverBeam;
    [SerializeField] private AnimationCurve _widthOverLifetime;
    [SerializeField] private Texture2D _noiseTexture;
    [SerializeField] private Vector3 _noiseSpeed;
    [SerializeField] private Vector3 _noiseStrength;
    [SerializeField] private Vector3 _noiseFrequency;
    [SerializeField] private Vector3 _dampening;
    [SerializeField] private AnimationCurve _noiseOverLength;
    [SerializeField] private AnimationCurve _noiseOverLifetime;
    [SerializeField] private bool _followTarget;
    [SerializeField] private AnimationCurve _gorwthCurve;
    [SerializeField] private bool _reverseGrowth;
    [SerializeField] private int _spans;

    public Transform Start;
    public Transform Target;

    public LineRenderer _line;
    private float _timeLived;
    private float _normalTime;
    private Vector3 _targetVector;
    private float _distance;
    private float _startWidth;
    private Vector2 _startNoiseX, _startNoiseY, _startNoiseZ;
    private int _currentSpans, _currentPoints;
    private Vector3[] _straightLine, _previousPosistions;

    private void Awake()
    {
        _line = GetComponent<LineRenderer>();
        _line.useWorldSpace = true;
        _startWidth = _line.widthMultiplier;
        Kill();
    }

    private void Update()
    {
        if (Input.GetKeyUp("space"))
        {
            _startNoiseX = new Vector2(Random.Range(0.00f, 1.00f), Random.Range(0.00f, 1.00f));
            _startNoiseY = new Vector2(Random.Range(0.00f, 1.00f), Random.Range(0.00f, 1.00f));
            _startNoiseZ = new Vector2(Random.Range(0.00f, 1.00f), Random.Range(0.00f, 1.00f));
            Spawn();
        }

        if (_currentSpans<2)
        {
            return;
        }

        if (_timeLived > _lifetime)
        {
            Kill();
            return;
        }

        updateLine();
        _timeLived += Time.deltaTime;
    }

    public void Spawn()
    {
        if (_currentSpans > 1)
        {
            return;
        }
        _timeLived = _normalTime = 0f;
        _line.positionCount = _currentPoints = _spans+1;
        _currentSpans = _spans;
        getVector();
    }

    private void Kill()
    {
        _line.positionCount = _currentSpans = _currentPoints = 0;
    }

    private void updateLine()
    {
        _normalTime = _timeLived / _lifetime;
        growBeam();
        applyWidthOverLifetime();
        applyColorOverLifetime();
        applyNoise();
    }

    private void getVector()
    {
        var heading = Target.position - Start.position;
        _distance = heading.magnitude;
        _targetVector = heading / _distance;
    }

    private void growBeam()
    {
        var scale = _gorwthCurve.Evaluate(_normalTime);
        var positions = new Vector3[_currentPoints];
        for (var i = 0; i < _currentPoints; i++)
        {
            var offset = i / (float)_currentSpans * _distance * scale;
            positions[i] = Start.position + _targetVector * offset;
        }
        _line.SetPositions(positions);
        _straightLine = positions;
    }

    private void applyWidthOverLifetime()
    {
        _line.widthMultiplier = _startWidth * _widthOverLifetime.Evaluate(_normalTime);
    }

    private void applyColorOverLifetime()
    {
        var c = _colorOverLifetime.Evaluate(_normalTime);
        var input = _colorOverBeam;
        var outputColor = input.colorKeys;
        for (var i = 0; i < outputColor.Length; i++)
        {
            outputColor[i].color *= c;
        }

        var outputAlpha = input.alphaKeys;
        for (var i = 0; i < outputAlpha.Length; i++)
        {
            outputAlpha[i].alpha *= c.a;
        }

        var output = new Gradient();
        output.SetKeys(outputColor, outputAlpha);
        _line.colorGradient = output;
    }

    private void applyNoise()
    {
        // TODO: Repeat this for Y and Z
        var lifeMultiplier = _noiseOverLifetime.Evaluate(_normalTime);
        var uvOffset = new Vector2(_startNoiseX.x,  _timeLived * _noiseSpeed.x + _startNoiseX.y );
        var positions = new Vector3[_currentPoints];
        _line.GetPositions(positions);
        for (var i = 0; i < _currentPoints; i++)
        {
            var pct = i / (float)_currentSpans;
            var localMultiplier = _noiseOverLength.Evaluate(pct);
            var offset = getPixelValue(new Vector2((uvOffset.x+pct)* _noiseFrequency.x, uvOffset.y * _noiseFrequency.x), 0);
            offset *= 2f;
            offset -= 1f;
            offset *= _noiseStrength.x * lifeMultiplier * localMultiplier;
            var pos = positions[i];
            pos += Vector3.up*offset;
            positions[i] = pos;
        }
        _line.SetPositions(positions);
        // TODO: Dampen the noise
        _previousPosistions = positions;
    }

    private float getPixelValue(Vector2 uv, int channel)
    {
        var uPos = Mathf.RoundToInt(uv.x % 1 * _noiseTexture.width);
        var vPos = Mathf.RoundToInt(uv.y % 1 * _noiseTexture.height);
        float output;
        switch (channel) {
            default:
                output = _noiseTexture.GetPixel(uPos, vPos).r;
                break;
            case 1:
                output = _noiseTexture.GetPixel(uPos, vPos).g;
                break;
            case 2:
                output = _noiseTexture.GetPixel(uPos, vPos).b;
                break;
        }
        return output;
    }


}
