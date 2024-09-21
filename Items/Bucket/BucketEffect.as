#include "RunnerTextures.as";

void onTick(CSprite@ this)
{
	CSpriteLayer@ buckethead = this.getSpriteLayer("buckethead");
	if (buckethead !is null)
	{
		int layer = 0;
		Vec2f headoffset(this.getFrameWidth() / 2, -this.getFrameHeight() / 2);
		Vec2f head_offset = getHeadOffset(this.getBlob(), -1, layer);
		
		headoffset += this.getOffset();
		headoffset += Vec2f(-head_offset.x, head_offset.y);
		headoffset += Vec2f(0, -3);
		
		buckethead.SetOffset(headoffset);

		buckethead.SetVisible(this.isVisible());
		//buckethead.SetRelativeZ(layer * 0.25f + 0.1f);
	}
}
