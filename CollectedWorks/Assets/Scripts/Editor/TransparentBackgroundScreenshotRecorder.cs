using System.Collections;
using System.IO;
using UnityEngine;

/*

Usage:
1. Attach this script to your chosen camera's game object.
2. Set that camera's Clear Flags field to Solid Color.
3. Use the inspector to set frameRate and framesToCapture
4. Choose your desired resolution in Unity's Game window (must be less than or equal to your screen resolution)
5. Turn on "Maximise on Play"
6. Play your scene. Screenshots will be saved to YourUnityProject/Screenshots by default.

*/

public class TransparentBackgroundScreenshotRecorder : MonoBehaviour
{
	#region public fields

	[Tooltip("A folder will be created with this base name in your project root")] public string folderBaseName = "Screenshots";
	[Tooltip("How many frames should be captured per second of game time")] public int frameRate = 24;
	[Tooltip("How many frames should be captured before quitting")] public int framesToCapture = 24;

	#endregion


	#region private fields

	private string folderName = "";
	private GameObject whiteCamGameObject;
	private Camera whiteCam;
	private GameObject blackCamGameObject;
	private Camera blackCam;
	private Camera mainCam;
	private int frameCount; // how many frames we've rendered
	private bool done;
	private int screenWidth;
	private int screenHeight;
	private Texture2D textureBlack;
	private Texture2D textureWhite;
	private Texture2D textureTransparentBackground;

	#endregion


	private void Awake()
	{
		mainCam = gameObject.GetComponent<Camera>();
		CreateBlackAndWhiteCameras();
		CreateNewFolderForScreenshots();
		CacheAndInitialiseFields();
		Time.captureFramerate = frameRate;
	}

	private void LateUpdate()
	{
		if (!done)
		{
			StartCoroutine(CaptureFrame());
		}
		else
		{
			Debug.Log("Complete! " + frameCount + " frames rendered. File names are 0 indexed)");
			Debug.Break();
		}
	}

	private IEnumerator CaptureFrame()
	{
		yield return new WaitForEndOfFrame();
		if (frameCount < framesToCapture)
		{
			RenderCamToTexture(blackCam, textureBlack);
			RenderCamToTexture(whiteCam, textureWhite);
			CalculateOutputTexture();
			SavePng();
			frameCount++;
			Debug.Log("Rendered frame " + frameCount);
			frameCount++;
		}
		else
		{
			done = true;
			StopCoroutine("CaptureFrame");
		}
	}

	private void RenderCamToTexture(Camera cam, Texture2D tex)
	{
		cam.enabled = true;
		cam.Render();
		WriteScreenImageToTexture(tex);
		cam.enabled = false;
	}

	private void CreateBlackAndWhiteCameras()
	{
		whiteCamGameObject = new GameObject {name = "White Background Camera"};
		whiteCam = whiteCamGameObject.AddComponent<Camera>();
		whiteCam.CopyFrom(mainCam);
		whiteCam.backgroundColor = Color.white;
		whiteCamGameObject.transform.SetParent(gameObject.transform, true);

		blackCamGameObject = new GameObject {name = "Black Background Camera"};
		blackCam = blackCamGameObject.AddComponent<Camera>();
		blackCam.CopyFrom(mainCam);
		blackCam.backgroundColor = Color.black;
		blackCamGameObject.transform.SetParent(gameObject.transform, true);
	}

	private void CreateNewFolderForScreenshots()
	{
		// Find a folder name that doesn't exist yet. Append number if necessary.
		folderName = folderBaseName;
		var count = 1;
		while (Directory.Exists(folderName))
		{
			folderName = folderBaseName + count;
			count++;
		}

		Directory.CreateDirectory(folderName); // Create the folder
	}

	private void WriteScreenImageToTexture(Texture2D tex)
	{
		tex.ReadPixels(new Rect(0, 0, screenWidth, screenHeight), 0, 0);
		tex.Apply();
	}

	private void CalculateOutputTexture()
	{
		for (var y = 0; y < textureTransparentBackground.height; ++y)
		{
			// each row
			for (var x = 0; x < textureTransparentBackground.width; ++x)
			{
				// each column
				var alpha = textureWhite.GetPixel(x, y).r - textureBlack.GetPixel(x, y).r;
				alpha = 1.0f - alpha;
				Color color;
				if (alpha == 0f)
				{
					color = Color.clear;
				}
				else
				{
					color = textureBlack.GetPixel(x, y) / alpha;
				}

				color.a = alpha;
				textureTransparentBackground.SetPixel(x, y, color);
			}
		}
	}

	private void SavePng()
	{
		var frameName = $"{folderName}/{frameCount:D04} shot.png";
		var pngShot = textureTransparentBackground.EncodeToPNG();
		File.WriteAllBytes(frameName, pngShot);
	}

	private void CacheAndInitialiseFields()
	{
		screenWidth = Screen.width;
		screenHeight = Screen.height;
		textureBlack = new Texture2D(screenWidth, screenHeight, TextureFormat.RGB24, false);
		textureWhite = new Texture2D(screenWidth, screenHeight, TextureFormat.RGB24, false);
		textureTransparentBackground = new Texture2D(screenWidth, screenHeight, TextureFormat.ARGB32, false);
	}
}