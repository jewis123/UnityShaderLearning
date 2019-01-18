using UnityEngine;

public class CaremaEffect : MonoBehaviour {
    public Material mat;

     ///<summery>
     ///在渲染相机输出图像前应用指定shader效果
     ///</summery>
    private void OnRenderImage (RenderTexture src, RenderTexture dest) {
        Graphics.Blit (src, dest, mat);
    }
}