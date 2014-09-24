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

#import "cocos2d.h"

#import "AppDelegate.h"
#import "SettingsController.h"
#import "DataController.h"
#import "IntroLayer.h"
#import "config.h"

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  sharedSC = [SettingsController sharedSettingsController];
  
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
  [director_ setDisplayStats:sharedSC.debugging];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// for rotation and other messages
	[director_ setDelegate:self];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
  
  [director_ pushScene:[IntroLayer scene]];
  
  [self handleLaunchOptionsURL:(NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey]];
	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
//	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
  
  //game center
  [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
  [[GameKitHelper sharedGameKitHelper] setDelegate:self];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSettings) name:SETTINGS_UPDATED_NOTIFICATION object:nil];
	
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


//email
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
  [self handleLaunchOptionsURL:url];
  
  return YES;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1)
  {
    NSData * data = [NSData dataWithContentsOfURL:m_attachmentURL];
    nt_level * l = [[nt_level alloc] initWithData:data];

    [[DataController sharedDataController] addLevelWithName:[m_attachmentURL lastPathComponent] andLevel:l];
    
    [l release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CLOUD_UPDATED_NOTIFICATION object:nil];
  }
  
  [m_attachmentURL release];
  m_attachmentURL = NULL;
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
  
  [[DataController sharedDataController] loadLevelsFromCloudDirectory];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}


- (void)updateSettings
{
  [director_ setDisplayStats:sharedSC.debugging];
}


- (void)handleLaunchOptionsURL:(NSURL *)aURL
{
  if (m_attachmentURL != NULL)
  {
    return;
  }
  
  m_attachmentURL = [aURL copy];
  
  if (m_attachmentURL != nil && [m_attachmentURL isFileURL])
  {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to add the level '%@' to your collection?", [m_attachmentURL.lastPathComponent stringByDeletingPathExtension]] message:@"Note: It may take a moment for the level to show up in your collection." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    [alert release];
  }
}


#pragma mark -
#pragma mark Game Center


-(void) onLocalPlayerAuthenticationChanged{};

-(void) onFriendListReceived:(NSArray*)friends{};
-(void) onPlayerInfoReceived:(NSArray*)players{};

-(void) onScoresSubmitted:(bool)success{};
-(void) onScoresReceived:(NSArray*)scores{};


-(void) onAchievementReported:(GKAchievement*)achievement
{
  NSLog(@"Game Center Achievement %@ Reported", achievement.description);
}


-(void) onAchievementsLoaded:(NSDictionary*)achievements{};
-(void) onResetAchievements:(bool)success{};

-(void) onMatchFound:(GKMatch*)match{};
-(void) onPlayersAddedToMatch:(bool)success{};
-(void) onReceivedMatchmakingActivity:(NSInteger)activity{};

-(void) onPlayerConnected:(NSString*)playerID{};
-(void) onPlayerDisconnected:(NSString*)playerID{};
-(void) onStartMatch{};
-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID{};

-(void) onMatchmakingViewDismissed{};
-(void) onMatchmakingViewError{};
-(void) onLeaderboardViewDismissed{};
-(void) onAchievementsViewDismissed{};


- (void)didShowSomething
{
  [[CCDirector sharedDirector] pause];
  NSLog(@"SHOW");
}

- (void)didHideSomething
{
  [[CCDirector sharedDirector] resume];
  NSLog(@"HIDE");
}


- (void) dealloc
{
	[window_ release];
	[navController_ release];
	
	[super dealloc];
}
@end

