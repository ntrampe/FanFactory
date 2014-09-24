/*
 * Copyright (c) 2014 Nicholas Trampe
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

#import "TestScene.h"
#import "PackController.h"
#import "nt_pack.h"
#import "nt_leveldata.h"
#import "nt_button.h"
#import "nt_scrollLayer.h"
#import "StoreScene.h"
#import "nt_alertview.h"
#import "CCSprite+StretchableImage.h"

@implementation TestScene

+ (CCScene *) scene
{
  CCScene *scene = [CCScene node];
	
	TestScene * layer = [TestScene node];
  
  [scene addChild:layer];
	
	return scene;
}

- (id)init
{
  self = [super init];
  if (self) 
  {
    [self setBackGround:@"standard_sky.png" scaleMode:BGScaleModeStretch];
    
    sharedPC = [PackController sharedPackController];
    
    CCMenuItemFont * item = [CCMenuItemFont itemWithString:@"Test" block:^(id sender)
    {
      nt_alertview * alert = [[nt_alertview alloc] initWithContainer:[StoreScene node] message:@"Store" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
      [alert show];
      [alert release];
    }];
    
    CCMenu * menu = [CCMenu menuWithItems:item, nil];
    [self addChild:menu];
    
    CCSprite * s = [CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(300, 186)];
    s.position = self.screenCenter;
    [self addChild:s];
    
    [self addBackButton];
  }
  return self;
}


- (void)dealloc
{
  
  [super dealloc];
}


@end
