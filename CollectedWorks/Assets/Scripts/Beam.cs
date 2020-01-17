using System;
using TMPro;
using UnityEngine;

[RequireComponent(typeof(LineRenderer))]
public class Beam : MonoBehaviour
{
    [SerializeField] private float _lifetime;
    [SerializeField] private Gradient _colorOverLifetime;
    [SerializeField] private Gradient _colorOverBeam;
    [SerializeField] private AnimationCurve _widthOverLifetime;
    [SerializeField] private float _points;
    [SerializeField] private Texture2D noiseTexture;
    [SerializeField] private float _dampening;
    [SerializeField] private AnimationCurve _noiseOverLength;
    [SerializeField] private AnimationCurve _noiseOverLifetime;
    [SerializeField] private bool _followTarget;
    [SerializeField] private AnimationCurve _gorwthCurve;
    [SerializeField] private bool _reverseGrowth;
    [SerializeField] private int _spans;
    [SerializeField] private int test = 2;

    public Transform Start;
    public Transform Target;

    public LineRenderer _line;
    private float _timeLived;
    private float _normalTime;
    private Vector3 _targetVector;
    private float _distance;
    private float _startWidth;


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
            Debug.Log("Spawn!!");
            Spawn();
        }

        if (_line.positionCount<2)
        {
            return;
        }

        if (_timeLived > _lifetime)
        {
            Debug.Log("Lived for: " + _timeLived);
            Kill();
            return;
        }

        UpdateLine();
        _timeLived += Time.deltaTime;
    }

    public void Spawn()
    {
        _timeLived = _normalTime = 0f;
        _line.positionCount = _spans;
        getVector();
    }

    private void Kill()
    {
        _line.positionCount = 0;
    }

    private void UpdateLine()
    {
        _normalTime = _timeLived / _lifetime;
        growBeam();
        applyWidthOverLifetime();
        applyColorOverLifetime();
    }

    // Find Vector
    private void getVector()
    {
        var heading = Target.position - Start.position;
        _distance = heading.magnitude;
        Debug.Log("Distance = "+ _distance);
        _targetVector = heading / _distance;
    }

    private void growBeam()
    {
        _line.positionCount = _spans;
        var scale = _gorwthCurve.Evaluate(_normalTime);
        var positions = new Vector3[_spans];
        for (var i = 0; i < _spans; i++)
        {
            var offset = (float)i / (_spans - 1f) * _distance * scale;
            positions[i] = Start.position + _targetVector * offset;
        }
        _line.SetPositions(positions);
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
}
