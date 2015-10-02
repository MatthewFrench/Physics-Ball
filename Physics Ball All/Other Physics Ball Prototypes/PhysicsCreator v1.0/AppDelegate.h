//
#import <Cocoa/Cocoa.h>
#import <Box2D/Box2D.h>
#import "QueryCallback.h"
#import "Shape.h"
#import "MainView.h"
#import "MainWindow.h"

#define PTM_RATIO 32
#define FPS 60

@interface AppDelegate : NSObject {
    IBOutlet NSWindow *window, *newProjectWindow, *cardWindow;
	
	IBOutlet NSButton* newProjectBtn, *makeBall, *makePolygon, *makeBox, *makeRope;
	IBOutlet NSTextField* shapeNameTxt, *shapeFrictionTxt, *shapeDensityTxt, *shapeRestitutionTxt, 
	*shapeRotationTxt, *shapeTypeTxt, *gravityXTxt, *gravityYTxt;
	IBOutlet NSPanel *toolsPanel;
	
	IBOutlet MainView *mainView;
	NSTimer* timer;
	BOOL physicsOn;
	
	NSMutableArray* shapes;
	CGPoint cameraPos, mousePos;
	
	b2World* world;
	b2Body* groundBody;
	b2MouseJoint* mouseJoint;
	b2Vec2 gravity;
	
	Shape* selectedShape;
}

- (IBAction)newProject:(id)sender;
- (IBAction)openPcFile:(id)sender;
- (IBAction)quit:(id)sender;

- (void)tick;
- (void)drawScreen;
- (void)drawHoldCircle:(CGPoint)position;
- (void)mouseDown:(NSEvent*)event;
- (void)mouseDragged:(NSEvent*)event;
- (void)mouseUp:(NSEvent*)event;
- (void)keydown:(UniChar)key;
- (void)keyup:(UniChar)key;

- (IBAction)startPhysics:(id)sender;
- (IBAction)endPhysics:(id)sender;

- (void)createPhysicsWorld:(CGSize)size infinite:(BOOL)infinite;
- (IBAction)makeBall:(id)sender;
- (IBAction)makeBox:(id)sender;
- (IBAction)makePolygon:(id)sender;
- (IBAction)makeRope:(id)sender;

- (IBAction)shapeNameTxtChange:(id)sender;
- (IBAction)shapeFrictionTxtChange:(id)sender;
- (IBAction)shapeDensityTxtChange:(id)sender;
- (IBAction)shapeRotationTxtChange:(id)sender;
- (IBAction)shapeRestitutionTxtChange:(id)sender;
- (IBAction)shapeTypeTxtChange:(id)sender;
- (IBAction)gravityXTxtChange:(id)sender;
- (IBAction)gravityYTxtChange:(id)sender;

- (void)updateTextFields;

- (void) drawBox:(float)shapew h:(float)shapeh rotation:(float)rot x:(float)x y:(float)y;

@end
