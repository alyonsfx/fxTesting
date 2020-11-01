using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UICard : MonoBehaviour
{
    [SerializeField] private RectTransform _fill;
    [SerializeField] private int _startCount;
    [SerializeField] private int _targetCount;
    [SerializeField] private int _totalCount;
    [SerializeField] private Text _progressText;
    [SerializeField] private Color _progressColor;
    [SerializeField] private Color _completeColor;
    [SerializeField] private Animation _rootAnim;
    [SerializeField] private Animation _barAnim;


    private void Awake()
    {
        var pct = (float)_startCount/_totalCount;
        _fill.anchorMax = new Vector2(pct, 1f);
        _progressText.text = string.Format("{0}/{1}", _startCount, _totalCount);
    }

    private void OnEnable()
    {
        _rootAnim.Play();
        StartCoroutine(DoBarUpdate());
    }

    IEnumerator DoBarUpdate()
    {
        while(_rootAnim.isPlaying)
        {
            yield return null;
        }

        var start = (float)_startCount/_totalCount;
        var target = (float)_targetCount/_totalCount;

        var t = 0f;
        while(t<0.5f)
        {
            var temp = Mathf.SmoothStep(start, target, t/0.5f);
            _fill.anchorMax = new Vector2(temp, 1f);
            t+= Time.deltaTime;
            yield return null;
        }


        if(_targetCount == _totalCount)
        {
            _fill.GetComponent<Image>().color = _completeColor;
            _barAnim.Play();
            _progressText.text = "UPGRADE";
        }
        else
        {
            _progressText.text = string.Format("{0}/{1}", _targetCount, _totalCount);
        }
    }
}
