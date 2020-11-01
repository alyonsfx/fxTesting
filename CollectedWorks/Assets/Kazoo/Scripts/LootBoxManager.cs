using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System.Linq;

public class LootBoxManager : MonoBehaviour
{
    [SerializeField] private List<Animator> _cards = new List<Animator>();
    [SerializeField] private MeshRenderer _background;
    [SerializeField] private ParticleSystem _glow;
    [SerializeField] private GameObject _box;
    [SerializeField] private Button _openButton;
    [SerializeField] private Animation _ui;
    [SerializeField] private Text _text;

    private int _cardIndex = 0;
    private Animator currentCard;
    private Material backgroundMat;
    private Animator controller;

    private void Awake()
    {
        backgroundMat = _background.material;
        controller = GetComponent<Animator>();
        controller.enabled = false;
        _ui.gameObject.SetActive(false);
        _glow.gameObject.SetActive(false);
        _box.SetActive(false);
        _openButton.interactable = false;
        _text.enabled = false;
    }

    private void Update()
    {
        if (Input.GetKeyDown("space"))
        {
            _box.SetActive(true);
            controller.enabled = true;
            _openButton.interactable = true;
            _text.enabled = true;
        }
    }

    public void ShowNext()
    {
        if(currentCard != null)
        {
            currentCard.SetTrigger("Fade");
        }

        if(_cardIndex >= _cards.Count)
        {
            _glow.Stop();
            StartCoroutine(SpecialGlow(0f));
            _ui.gameObject.SetActive(true);
            _openButton.gameObject.SetActive(false);
            _text.color = new Color(1f,1f,1f,1f);
            _text.text = "Continue";
        }
        else
        {
            _openButton.interactable = false;
            _text.color = new Color(1f,1f,1f,0.5f);
        }
        controller.SetTrigger("Open");
    }

    public void SpawnCard()
    {
        if(_cardIndex >= _cards.Count)
        {
            return;
        }
        else if(_cardIndex < _cards.Count)
        {
            var card = Instantiate(_cards[_cardIndex]);
            StartCoroutine(ButtonDelay(card, _cardIndex != _cards.Count));
            if(_cardIndex == _cards.Count-1)
            {
                StartCoroutine(SpecialGlow(1f));
                controller.SetBool("More", false);
            }
            _cardIndex ++;
        }
    }

    IEnumerator ButtonDelay(Animator card, bool reset)
    {
        yield return new WaitForSeconds(1f);
        currentCard = card;
        _openButton.interactable = true;
        _text.color = new Color(1f,1f,1f,1f);

    }

    IEnumerator SpecialGlow(float target)
    {
        var startValue = backgroundMat.GetFloat("_Intensity");
        var duration = startValue > target ? 0.3f : 0.5f;
        var t = 0f;
        while(t<duration)
        {
            var temp = Mathf.SmoothStep(startValue, target, t/duration);
            backgroundMat.SetFloat("_Intensity", temp);
            t+= Time.deltaTime;
            yield return null;
        }
    }
}
