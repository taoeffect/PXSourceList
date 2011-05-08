//
//  AppDelegate.m
//  PXSourceList
//
//  Created by Alex Rozanski on 08/01/2010.
//  Copyright 2010 Alex Rozanski http://perspx.com
//

#import "AppDelegate.h"
#import "NSDictionary+TERecord.h"

#define NSARY(...)	[NSMutableArray arrayWithObjects:__VA_ARGS__, nil]
#define NSINT(_n)	[NSNumber numberWithInt:_n]
#define NSIMG(_n)	[NSImage imageNamed:_n]

@protocol SourceListItem
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSImage *icon;
@property (nonatomic, retain) NSMutableArray *children;
@end

@implementation AppDelegate

#pragma mark -
#pragma mark Init/Dealloc

- (void)awakeFromNib
{
	[selectedItemLabel setStringValue:@"(none)"];
	
	sourceListItems = [[NSMutableArray alloc] initWithObjects:
					   _MD(@"title", @"LIBRARY",
						   @"identifier", @"library",
						   @"children",
						   NSARY(_MD(@"title", @"Music",
									 @"identifier", @"music",
									 @"icon", NSIMG(@"music")),
								 _MD(@"title", @"Movies",
									 @"identifier", @"movies",
									 @"icon", NSIMG(@"movies")),
								 _MD(@"title", @"Podcasts",
									 @"identifier", @"podcasts",
									 @"icon", NSIMG(@"podcasts")),
								 _MD(@"title", @"Audiobooks",
									 @"identifier", @"audiobooks",
									 @"icon", NSIMG(@"audiobooks")))),
					   _MD(@"title", @"PLAYLISTS",
						   @"identifier", @"playlists",
						   @"children",
						   NSARY(_MD(@"title", @"Playlist1",
									 @"identifier", @"playlist1",
									 @"icon", NSIMG(@"playlist")),
								 _MD(@"title", @"Playlist Group",
									 @"identifier", @"playlistgroup",
									 @"icon", NSIMG(@"playlistFolder"),
									 @"children",
									 NSARY(_MD(@"title", @"Child Playlist",
											   @"identifier", @"childplaylist",
											   @"icon", NSIMG(@"playlist")))),
								 _MD(@"title", @"Playlist1",
									 @"identifier", @"playlist1",
									 @"icon", NSIMG(@"playlist")),
								 _MD(@"title", @"Playlist1",
									 @"identifier", @"playlist1",
									 @"icon", NSIMG(@"playlist")))),
					   nil];
	[sourceList reloadData];
}

- (void)dealloc
{
	[sourceListItems release];
	[super dealloc];
}

#pragma mark -
#pragma mark Source List Data Source Methods

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id<SourceListItem>)item
{
	return item ? [item.children count] : [sourceListItems count];
}

- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id<SourceListItem>)item
{
	return item ? [item.children objectAtIndex:index] : [sourceListItems objectAtIndex:index];
}

- (id)sourceList:(PXSourceList*)aSourceList objectValueForItem:(id<SourceListItem>)item
{
	return item.title;
}


- (void)sourceList:(PXSourceList*)aSourceList setObjectValue:(id)object forItem:(id<SourceListItem>)item
{
	item.title = object;
}

- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id<SourceListItem>)item
{
	return [item.children count] > 0;
}

- (BOOL)sourceList:(PXSourceList*)aSourceList itemHasIcon:(id<SourceListItem>)item
{
	return !!item.icon;
}

- (NSImage*)sourceList:(PXSourceList*)aSourceList iconForItem:(id<SourceListItem>)item
{
	return item.icon;
}

- (NSMenu*)sourceList:(PXSourceList*)aSourceList menuForEvent:(NSEvent*)theEvent item:(id<SourceListItem>)item
{
	if ([theEvent type] == NSRightMouseDown || ([theEvent type] == NSLeftMouseDown && ([theEvent modifierFlags] & NSControlKeyMask) == NSControlKeyMask)) {
		NSMenu * m = [[NSMenu alloc] init];
		if (item != nil)
			[m addItemWithTitle:item.title action:nil keyEquivalent:@""];
		else
			[m addItemWithTitle:@"clicked outside" action:nil keyEquivalent:@""];
		return [m autorelease];
	}
	return nil;
}

#pragma mark -
#pragma mark Source List Delegate Methods

- (BOOL)sourceList:(PXSourceList*)aSourceList isGroupAlwaysExpanded:(id<SourceListItem>)group
{
	return [group.identifier isEqualToString:@"library"];
}

- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
	NSIndexSet *selectedIndexes = [sourceList selectedRowIndexes];
	
	//Set the label text to represent the new selection
	if([selectedIndexes count]>1)
		[selectedItemLabel setStringValue:@"(multiple)"];
	else if([selectedIndexes count]==1) {
		NSString *identifier = [[sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
		
		[selectedItemLabel setStringValue:identifier];
	}
	else {
		[selectedItemLabel setStringValue:@"(none)"];
	}
}

- (void)sourceListDeleteKeyPressedOnRows:(NSNotification *)notification
{
	NSIndexSet *rows = [[notification userInfo] objectForKey:@"rows"];
	
	NSLog(@"Delete key pressed on rows %@", rows);
	
	//Do something here
}

@end
