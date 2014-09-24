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

#import "LevelEditSelectionScene.h"
#import "LevelEditingScene.h"
#import "LevelEditingTutorial.h"
#import "GameScene.h"
#import "DataController.h"
#import "LevelDocument.h"
#import "SettingsController.h"
#import "config.h"
#import "CCSprite+StretchableImage.h"

#define LEVEL_OFFSET 25

@implementation LevelEditSelectionScene

+ (CCScene *) scene
{
  CCScene *scene = [CCScene node];
	
	LevelEditSelectionScene * layer = [LevelEditSelectionScene node];
  
  [scene addChild:layer];
	
	return scene;
}


- (id)init
{
  self = [super init];
  if (self) 
  {
    sharedDC = [DataController sharedDataController];
    sharedSC = [SettingsController sharedSettingsController];
    
    m_selectionLayer = [[nt_scrollSelectionLayer alloc] init];
    m_selectionLayer.selectionDelegate = self;
    m_selectionLayer.editing = YES;
    [self addChild:m_selectionLayer];
    
//    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString * documentsDirectory = [paths objectAtIndex:0];
//    NSFileManager * fm = [NSFileManager defaultManager];
//    NSArray * dirContents = [fm contentsOfDirectoryAtPath:documentsDirectory error:nil];
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.dat'"];
//    NSArray * names = [dirContents filteredArrayUsingPredicate:filter];
    
//    m_data = [[CCArray alloc] init];
//    
//    for (NSString * s in names)
//    {
//      [m_data addObject:[s stringByDeletingPathExtension]];
//    }
    
    m_newFileAlert = [[nt_uialerttext alloc] initWithTitle:@"Enter New Level Name:"];
    [m_newFileAlert setDelegate:self];
    
    CCMenuItemFont * add = [CCMenuItemFont itemWithString:@"Add" target:m_newFileAlert selector:@selector(show)];
    CCMenuItemFont * ref = [CCMenuItemFont itemWithString:@"Refresh" target:self selector:@selector(updateLevels)];
    
    add.color = ref.color = ccWHITE;
    CCMenu * menu = [CCMenu menuWithItems:add, ref, nil];
    menu.position = CGPointMake(self.screenSize.width/2, add.contentSize.height/2 + 20);
    [menu alignItemsHorizontallyWithPadding:LEVEL_OFFSET];
    [self addChild:menu];
    
    CCSprite * s = [CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(320, 60)];
    s.position = menu.position;
    [self addChild:s z:-1];
    
    m_tutorial = [[nt_tutorial alloc] init];
    [m_tutorial setDelegate:self];
    [self addChild:m_tutorial];
    
    NSString * firstState = @"Welcome to the Level Editor!\nPress the 'Add' button to add a level.";
    CGPoint firstPoint = ccpAdd(menu.position, add.position);
    
    [m_tutorial addStateString:firstState andArrowLocation:firstPoint forState:0];
    [m_tutorial addState:1];
    m_tutorial.autoNext = NO;
    m_tutorial.autoRemoveArrow = NO;
    
    [m_tutorial setArrowScale:self.screenSize.width / STANDARD_SCREEN_WIDTH];
    
    [self scheduleUpdate];
  }
  return self;
}


- (void)dealloc
{
  //[m_data release];
  [m_selectionLayer release];
  [super dealloc];
}


- (void)onExit
{
  [super onExit];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [m_tutorial end];
}


- (void)onEnter
{
  [super onEnter];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLevels) name:CLOUD_UPDATED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectionLayer) name:CLOUD_UPDATED_NOTIFICATION object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectionLayer) name:NSMetadataQueryDidUpdateNotification object:nil];
  
  if (sharedSC.editingTutorial)
  {
    [m_tutorial scheduleOnce:@selector(start) delay:1.0f];
  }
  else
  {
    [self removeChild:m_tutorial cleanup:YES];
    [m_tutorial end];
  }
  
  [self updateLevels];
}


- (void)updateSelectionLayer
{
  [m_selectionLayer reloadData];
  NSLog(@"updateSelectionLayer");
}


- (void)updateLevels
{
  [sharedDC loadLevelsFromCloudDirectory];
  NSLog(@"updateLevels");
}


- (void)goToLevel:(LevelDocument *)aLevel
{
  [m_selectionLayer setEnabled:NO];
  
  [aLevel openWithCompletionHandler:^(BOOL success)
  {
    [m_selectionLayer setEnabled:YES];
    if (success)
    {
      if (sharedSC.editingTutorial)
      {
        [m_tutorial end];
        [self goToScene:[LevelEditingTutorial sceneWithLevelDocument:aLevel]];
      }
      else
      {
        [self goToScene:[LevelEditingScene sceneWithLevelDocument:aLevel]];
      }
    }
    else
    {
      UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Could not open level. Please try again later." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
      [alert show];
      [alert release];
    }
  }];
}


- (BOOL)levelExists:(NSString *)aLevel
{
  aLevel = [aLevel stringByAppendingString:@".dat"];
  
  for (LevelDocument * doc in sharedDC.levels)
  {
    if ([doc.name isEqualToString:aLevel])
      return TRUE;
  }
  
  return FALSE;
}

- (void)addLevelWithName:(NSString *)aName
{
  [sharedDC addLevelWithName:aName];
  
  aName = [aName stringByReplacingOccurrencesOfString:@".dat" withString:@""];
  
  nt_scrollSelectionCell * cell = [nt_scrollSelectionCell cellWithText:aName sprite:[CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(150, 95)]];
  [m_selectionLayer insertCell:cell];
}


- (void)uialertText:(nt_uialerttext *)sender didEnterText:(NSString *)aText
{
  NSRange range = [aText rangeOfString:@"^[A-Za-z0-9_ ]+$" options:NSRegularExpressionSearch];
  
  if (range.location == NSNotFound)
  {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Invalid file name!\nPlease use letters, numbers, underscores and spaces only." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
  else if ([self levelExists:aText])
  {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"That file already exists!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
  else
  {
    aText = [NSString stringWithFormat:@"%@.dat", aText];
    [self addLevelWithName:aText];
    nt_level * l = [[nt_level alloc] init];
    [l saveToFile:aText];
    [l release];
    
    if (sharedSC.editingTutorial)
    {
      [m_tutorial scheduleOnce:@selector(next) delay:0.5f];
    }
  }
}


- (void)update:(ccTime)dt
{
  self.velocity = m_selectionLayer.velocity;
}


- (void)selectionLayer:(nt_scrollSelectionLayer *)selectionLayer didSelectCell:(nt_scrollSelectionCell *)cell atIndex:(NSInteger)index
{
  [self goToLevel:[sharedDC.levels objectAtIndex:index]];
//  [self hideSpritesStartingFromNode:self.parent animated:YES];
//  [self performSelector:@selector(goToLevel:) withObject:[m_data objectAtIndex:index] afterDelay:0.4f];
}


- (void)selectionLayer:(nt_scrollSelectionLayer *)selectionLayer didDeleteCell:(nt_scrollSelectionCell *)cell atIndex:(NSInteger)index
{
  [sharedDC removeLevelWithName:[cell.title stringByAppendingString:@".dat"]];
  
  [m_selectionLayer deleteCell:cell];
}


- (CGFloat)selectionLayerWidthOffset:(nt_scrollSelectionLayer *)selectionLayer
{
  return 20.0f;
}


- (NSInteger)numberOfCellsInSelectionLayer:(nt_scrollSelectionLayer *)selectionLayer
{
  return [sharedDC.levels count];
}


- (nt_scrollSelectionCell *)selectionLayer:(nt_scrollSelectionLayer *)selectionLayer cellForIndex:(NSInteger)index
{
  NSString * name = [(LevelDocument *)[sharedDC.levels objectAtIndex:index] name];
  
  name = [name stringByReplacingOccurrencesOfString:@".dat" withString:@""];
  
  nt_scrollSelectionCell * cell = [nt_scrollSelectionCell cellWithText:name sprite:[CCSprite spriteWithStretchableImageNamed:@"stretch_container.png" withLeftCapWidth:18 topCapHeight:20 size:CGSizeMake(150, 95)]];
  return cell;
}


- (void)tutorial:(nt_tutorial *)sender didUpdateTutorialState:(unsigned int)aState
{
  switch (aState)
  {
    case 1:
      [m_tutorial addAlertWithText:@"Now select the level to start editing it."];
      [m_tutorial pointArrowToLocation:self.screenCenter forceDirection:kArrowDirectionUp];
      break;
      
    default:
      break;
  }
}


@end
