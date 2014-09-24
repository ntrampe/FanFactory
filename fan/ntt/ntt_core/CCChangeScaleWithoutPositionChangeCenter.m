/*
 * Copyright (c) 2013 Nicholas Trampe
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

#import "CCChangeScaleWithoutPositionChangeCenter.h"


@implementation CCChangeScaleWithoutPositionChangeCenter

+(id) actionWithScale: (CGPoint) scale
{
  return [[[self alloc] initWithScale:scale]autorelease];
}

-(id) initWithScale:(CGPoint) scale
{
  if( (self=[super init]) )
  {
    newScale = scale;
    
  }
  return self;
}

-(id) copyWithZone: (NSZone*) zone
{
  CCActionInstant *copy = [[[self class] allocWithZone: zone] initWithScale:newScale];
  return copy;
}

-(void) startWithTarget:(id)aTarget
{
  [super startWithTarget:aTarget];
  
  CCNode *node=(CCNode*) aTarget;
  
  CGPoint oldDistance=ccp(0.f,0.f),newDistance=oldDistance,translate=oldDistance;
  
  newScale.x = (newScale.x == 0.f) ? node.scaleX : newScale.x;
  newScale.y = (newScale.x == 0.f) ? node.scaleY : newScale.y;
  
  if (node.anchorPoint.x != 0.5f)
  {
    oldDistance.x=(0.5f-node.anchorPoint.x)*node.contentSize.width*node.scaleX;
    newDistance.x=(0.5f-node.anchorPoint.x)*node.contentSize.width*newScale.x;
  }
  
  if (node.anchorPoint.y !=0.5f)
  {
    oldDistance.y=(0.5f-node.anchorPoint.y)*node.contentSize.height*node.scaleY;
    newDistance.y=(0.5f-node.anchorPoint.y)*node.contentSize.height*newScale.y;
  }
  
  translate= ccpSub(newDistance,oldDistance);
  
  node.scaleX=newScale.x;
  node.scaleY=newScale.y;
  
  [node setPosition:ccpSub(node.position,translate)];
}
@end
