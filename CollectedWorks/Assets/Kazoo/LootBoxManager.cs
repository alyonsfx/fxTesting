using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LootBoxManager : MonoBehaviour
{
    [SerializeField] private List<Animator> _cards = new List<Animator>();
    [SerializeField] private Button _openButton;

    private int _cardIndex = 0;
    private Animator currentCard;

    public void SpawnCard()
    {
        if(_cardIndex < _cards.Count)
        {
            var card = Instantiate(_cards[_cardIndex]);
            _cardIndex ++;
            StartCoroutine(ButtonDelay(card));
        }
    }

    public void FadeCard()
    {
        if(currentCard != null)
        {
            currentCard.SetTrigger("Fade");
        }
    }

    IEnumerator ButtonDelay(Animator card)
    {
        yield return new WaitForSeconds(1.25f);
        currentCard = card;
        _openButton.interactable = true;
    }
}
