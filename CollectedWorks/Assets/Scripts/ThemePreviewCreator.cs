using System.Collections;
using System.Collections.Generic;
using System.IO;
using N3twork.Mino.Engine;
using N3twork.Mino.Theme;
using UnityEngine;
using Sirenix.OdinInspector;

[RequireComponent(typeof(Camera))]
public class ThemePreviewCreator : MonoBehaviour
{
	[BoxGroup("Theme", CenterLabel = true), SerializeField] private TetrisThemeData themeData;
	[BoxGroup("Theme"), TitleGroup("Theme/Hard Drop Effect"), SerializeField] private GameObject hardDropEffectPrefab;
	[BoxGroup("Theme"), TitleGroup("Theme/Hard Drop Effect"), SerializeField] private bool hardDropIsParticle;
	[BoxGroup("Theme"), TitleGroup("Theme/Hard Drop Effect"), HideIf("hardDropIsParticle"), SerializeField] private Gradient hardDropTrailGradient;
	[BoxGroup("Theme"), TitleGroup("Theme/Hard Drop Effect"), HideIf("hardDropIsParticle"), SerializeField] private float hardDropTrailLength = 6f;
	[BoxGroup("Theme"), TitleGroup("Theme/Hard Drop Effect"), HideIf("hardDropIsParticle"), SerializeField] private Vector3 hardDropTrailStart = new Vector3(0f, -0.48f, 0f);
	[BoxGroup("Theme"), TitleGroup("Theme/Hard Drop Effect"), ShowIf("hardDropIsParticle"), SerializeField] private Color hardDropStreakColor = Color.white;
	[BoxGroup("Theme"), TitleGroup("Theme/Hard Drop Effect"), ShowIf("hardDropIsParticle"), SerializeField] private float trailPauseTime = 0.15f;

	[BoxGroup("Capture", CenterLabel = true), TitleGroup("Capture/Camera"), SerializeField] private float cameraSize = 17.9f;
	[BoxGroup("Capture"), TitleGroup("Capture/Camera"), SerializeField] private int frames = 3;
	[BoxGroup("Capture"), TitleGroup("Capture/Camera"), SerializeField] private float interval = 30f;
	[BoxGroup("Capture"), TitleGroup("Capture/Camera"), SerializeField] private bool captureFirstFrame;
	[BoxGroup("Capture"), TitleGroup("Capture/Output"), SerializeField] private int outputHeight = 2048;
	[BoxGroup("Capture"), TitleGroup("Capture/Output"), SerializeField] private int outputWidth = 1563;
	[BoxGroup("Capture"), TitleGroup("Capture/Output"), FilePath, SerializeField] private string folderName = "Theme Preview Capture";
#if UNITY_EDITOR
	[BoxGroup("Capture"), PropertySpace(SpaceBefore = 20, SpaceAfter = 30), GUIColor(1f, 0.5f, 0.5f), Button("Capture", 30)] private void S() { UnityEditor.EditorApplication.isPlaying = true; }
#endif

	// [FoldoutGroup("Scene Settings", Expanded = false), ToggleLeft, SerializeField] private bool debugScene;
	[FoldoutGroup("Scene Settings", Expanded = false), TitleGroup("Scene Settings/Minos"), SerializeField] private List<Transform> iMinos = new List<Transform>();
	[TitleGroup("Scene Settings/Minos"), SerializeField] private List<Transform> jMinos = new List<Transform>();
	[TitleGroup("Scene Settings/Minos"), SerializeField] private List<Transform> lMinos = new List<Transform>();
	[TitleGroup("Scene Settings/Minos"), SerializeField] private List<Transform> oMinos = new List<Transform>();
	[TitleGroup("Scene Settings/Minos"), SerializeField] private List<Transform> sMinos = new List<Transform>();
	[TitleGroup("Scene Settings/Minos"), SerializeField] private List<Transform> tMinos = new List<Transform>();
	[TitleGroup("Scene Settings/Minos"), SerializeField] private List<Transform> zMinos = new List<Transform>();
	[TitleGroup("Scene Settings/Preview Minos"), SerializeField] private List<Transform> iMinoPreviews = new List<Transform>();
	[TitleGroup("Scene Settings/Preview Minos"), SerializeField] private List<Transform> oMinoPreviews = new List<Transform>();
	[TitleGroup("Scene Settings/Preview Minos"), SerializeField] private List<Transform> tMinoPreviews = new List<Transform>();
	[TitleGroup("Scene Settings/Preview Minos"), SerializeField] private List<Transform> zMinoPreviews = new List<Transform>();
	[TitleGroup("Scene Settings/Ghost"), SerializeField] private List<Transform> ghostMinos = new List<Transform>();
	[TitleGroup("Scene Settings/Falling"), SerializeField] private Transform trailStart;
	[TitleGroup("Scene Settings/Other"), SerializeField] private SpriteRenderer template;

	private Camera cam;
	private int frameCount;
	private RenderTexture renderTex;
	private Texture2D screenCap;
	private float nextCaptureTime;
	private bool done;

#if UNITY_EDITOR
	private void Awake()
	{
		template.enabled = false;
		FolderSetup();
		TextureSetup();
		SetupCamera();
		Instantiate(themeData.BoardPrefab);
		SetupMinos();
		SetupHardDropTrail();
		nextCaptureTime = captureFirstFrame ? 0f : Time.time + interval;
	}

	private void LateUpdate()
	{
		if (Time.time >= nextCaptureTime)
		{
			if (frameCount < frames)
			{
				nextCaptureTime = Time.time + interval;
				StartCoroutine(CaptureFrame());
			}
			else
			{
				Debug.Log("Complete! " + frameCount + " previews rendered");
				Destroy(renderTex);
				UnityEditor.EditorApplication.isPlaying = false;
			}
		}
	}


	#region Setup

	private void FolderSetup()
	{
		while (Directory.Exists(folderName))
		{
			return;
		}

		Directory.CreateDirectory(folderName);
	}

	private void TextureSetup()
	{
		screenCap = new Texture2D(outputWidth, outputHeight, TextureFormat.RGB24, false);
	}

	private void SetupCamera()
	{
		cam = GetComponent<Camera>();
		cam.orthographic = true;
		cam.orthographicSize = cameraSize;
		cam.clearFlags = CameraClearFlags.Color;
		renderTex = new RenderTexture(outputWidth, outputHeight, 24);
	}


	private void SetupMinos()
	{
		GenerateIMinos();
		GenerateJMinos();
		GenerateLMinos();
		GenerateOMinos();
		GenerateSMinos();
		GenerateTMinos();
		GenerateZMinos();
		GenerateIMinoPreviews();
		GenerateOMinoPreviews();
		GenerateTMinoPreviews();
		GenerateZMinoPreviews();
		GenerateGhostMinos();
	}

	private void SetupHardDropTrail()
	{
		if (hardDropIsParticle)
		{
			var targetPos = new Vector3(trailStart.position.x, 0f, 0f);
			var trail = Instantiate(hardDropEffectPrefab, targetPos, Quaternion.identity);
			var ps = trail.GetComponent<ParticleSystem>();
			var mainModule = ps.main;
			mainModule.startColor = hardDropStreakColor;
			mainModule.startSizeYMultiplier = 3f;
			ps.Stop();
			ps.Simulate(trailPauseTime);
		}
		else
		{
			var trail = Instantiate(hardDropEffectPrefab, trailStart.position, Quaternion.identity);
			var line = trail.GetComponent<LineRenderer>();
			line.SetPositions(new[] {hardDropTrailStart, Vector3.up * hardDropTrailLength});
			line.useWorldSpace = false;
			line.widthMultiplier = 3f;
			line.colorGradient = hardDropTrailGradient;
		}
	}


	#endregion


	#region MinoGeneration

	private void GenerateIMinos()
	{
		foreach (var mino in iMinos)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.I)
				{
					thisMino = tetromino.Monomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				Instantiate(thisMino, mino.position, Quaternion.identity);
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	private void GenerateJMinos()
	{
		foreach (var mino in jMinos)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.J)
				{
					thisMino = tetromino.Monomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				Instantiate(thisMino, mino.position, Quaternion.identity);
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	private void GenerateLMinos()
	{
		foreach (var mino in lMinos)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.L)
				{
					thisMino = tetromino.Monomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				Instantiate(thisMino, mino.position, Quaternion.identity);
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	private void GenerateOMinos()
	{
		foreach (var mino in oMinos)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.O)
				{
					thisMino = tetromino.Monomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				Instantiate(thisMino, mino.position, Quaternion.identity);
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	private void GenerateSMinos()
	{
		foreach (var mino in sMinos)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.S)
				{
					thisMino = tetromino.Monomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				Instantiate(thisMino, mino.position, Quaternion.identity);
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	private void GenerateTMinos()
	{
		foreach (var mino in tMinos)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.T)
				{
					thisMino = tetromino.Monomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				Instantiate(thisMino, mino.position, Quaternion.identity);
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	private void GenerateZMinos()
	{
		foreach (var mino in zMinos)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.Z)
				{
					thisMino = tetromino.Monomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				Instantiate(thisMino, mino.position, Quaternion.identity);
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	private void GenerateGhostMinos()
	{
		foreach (var mino in ghostMinos)
		{
			Instantiate(themeData.Ghost.Monomino.gameObject, mino.position, Quaternion.identity);
			mino.GetComponent<SpriteRenderer>().enabled = false;
		}
	}

	private void GenerateIMinoPreviews()
	{
		foreach (var mino in iMinoPreviews)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.I)
				{
					thisMino = tetromino.PreviewMonomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				var themeMino = Instantiate(thisMino, mino.position, Quaternion.identity);
				themeMino.transform.localScale = mino.localScale;
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	private void GenerateOMinoPreviews()
	{
		foreach (var mino in oMinoPreviews)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.O)
				{
					thisMino = tetromino.PreviewMonomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				var themeMino = Instantiate(thisMino, mino.position, Quaternion.identity);
				themeMino.transform.localScale = mino.localScale;
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	private void GenerateTMinoPreviews()
	{
		foreach (var mino in tMinoPreviews)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.T)
				{
					thisMino = tetromino.PreviewMonomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				var themeMino = Instantiate(thisMino, mino.position, Quaternion.identity);
				themeMino.transform.localScale = mino.localScale;
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	private void GenerateZMinoPreviews()
	{
		foreach (var mino in zMinoPreviews)
		{
			GameObject thisMino = null;
			foreach (var tetromino in themeData.Tetrominos)
			{
				if (tetromino.Letter == TetrominoLetter.Z)
				{
					thisMino = tetromino.PreviewMonomino.gameObject;
				}
			}

			if (thisMino != null)
			{
				var themeMino = Instantiate(thisMino, mino.position, Quaternion.identity);
				themeMino.transform.localScale = mino.localScale;
				mino.GetComponent<SpriteRenderer>().enabled = false;
			}
		}
	}

	#endregion


	#region Screencap

	private IEnumerator CaptureFrame()
	{
		yield return new WaitForEndOfFrame();
		WriteScreenImageToTexture();
		SavePng();
		Debug.Log("Rendered preview " + frameCount + " at " + Time.time);
		frameCount++;
	}

	private void WriteScreenImageToTexture()
	{
		RenderTexture.active = renderTex;
		cam.targetTexture = renderTex;
		cam.Render();
		screenCap.ReadPixels(new Rect(0, 0, outputWidth, outputHeight), 0, 0);
		cam.targetTexture = null;
		RenderTexture.active = null;
	}

	private void SavePng()
	{
		var themeName = themeData.name;
		themeName.Remove(themeName.Length - 5);
		var frameName = $"{folderName}/{themeName}_Preview_{frameCount:D04}.png";
		var pngShot = screenCap.EncodeToPNG();
		File.WriteAllBytes(frameName, pngShot);
	}

	#endregion


#endif
}
