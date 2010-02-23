/*	
import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;
*/

package de.websector.utils.tools.skins
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.ListEvent;
	import mx.states.State;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.Skin;
	import spark.events.IndexChangeEvent;
	
	/**
	 * Testing states of skin classes in Flex 4 using WSSkinStatesTester
	 * 
	 * @author	Jens Krause [www.websector.de]
	 * @date	09/06/09
	 * @see		http://www.websector.de/blog/2009/09/06/testing-states-of-skin-classes-in-flex-4-using-wsskinstatestester
	 * 
	 */
	
	public class WSSkinStatesTester extends SkinnableContainer
	{
		/**
		 * Selected skin 
		 * 
		 */		
		protected var _selectedSkin: Skin;
		
		/**
		 * Flag for setting new skinStates 
		 * 
		 */		
		protected var skinStatesChanged: Boolean = false;
		
		/**
		 * Flag for setting new skin 
		 * 
		 */		
		protected var skinsChanged: Boolean = false;
		
		/**
		 * List of all skins
		 * 
		 */		
		protected var _skins: ArrayList = new ArrayList();
		
		/**
		 * List of all skinStates of selected skin 
		 * 
		 */		
		protected var skinStates: ArrayList = new ArrayList();	
		
		/**
		 * ComboBox for selecting skins, which is a required part of the skin
		 *  
		 */		
		[SkinPart(required="true")]
		public var ddlSkins: DropDownList;
		
		/**
		 * ComboBox for selecting states, which is a required part of the skin
		 *  
		 */			
		[SkinPart(required="true")]
		public var ddlStates: DropDownList;
		
		/**
		 * Container to show selected skin
		 *  
		 */	
		[SkinPart(required="true")]
		public var skinHolder: Group;
		
		/**
		 * Versions number
		 *  
		 */	
		protected static const VERSION: String = "v.0.3";
		
		/**
		 * Project URL
		 *  
		 */	
		protected static const URL: String = "http://www.websector.de/blog/2009/09/06/testing-states-of-skin-classes-in-flex-4-using-wsskinstatestester";
		
		/**
		 *  Constructor 
		 *  
		 */	
		public function WSSkinStatesTester()
		{
			super();
			
			// initializeStyles();
			if( getStyle('skinClass') == undefined )
				setStyle("skinClass", de.websector.utils.tools.skins.WSSkinStatesTesterSkin );
		}
		
		
		
		/**
		 * Initialize a default style definitions
		 *  
		 */
/*		private function initializeStyles():void
		{
			var css: CSSStyleDeclaration = styleManager.getStyleDeclaration("de.websector.utils.tools.skins.WSSkinStatesTester");
			
			if ( !css )
			{
				css = new CSSStyleDeclaration();
				
				css.defaultFactory = function():void
				{
					this.skinClass = WSSkinStatesTesterSkin;
				}
				
				styleManager.setStyleDeclaration("de.websector.utils.tools.skins.WSSkinStatesTester", css, true);
				
			}
		}*/
		
		//--------------------------------------------------------------------------
		//
		// life cycle
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @inheritDoc
		 * 
		 */		
		override protected function commitProperties() : void
		{
			super.commitProperties();
			
			if ( ddlSkins != null && skinsChanged )
			{				
				ddlSkins.dataProvider = _skins;
				selectedSkin = _skins.getItemAt( 0 ) as Skin;
				
				skinsChanged = false;
			}
			
			if ( ddlStates != null && skinStatesChanged )
			{				
				ddlStates.dataProvider = skinStates;
				// workaround to update dropdown list, cbStates.selectedIndex = 0 won't work...
				callLater( updateCbStates )
				skinStatesChanged = false;
			}
		}
		
		/**
		 * Just a helper method to udate selected item of the drop down for states 
		 * 
		 */		
		protected function updateCbStates():void
		{
			ddlStates.selectedItem = skinStates.getItemAt( 0 ) as State;
		}
		
		/**
		 *  @inheritDoc
		 * 
		 */			
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == ddlSkins )
			{
				ddlSkins.dataProvider = _skins;
				ddlSkins.labelFunction = getSkinClassName;
				ddlSkins.addEventListener( ListEvent.CHANGE, cbSkinsChangeHandler );
			}
			else if (instance == ddlStates )
			{
				ddlStates.dataProvider = skinStates;
				ddlStates.labelFunction = getStateName;
				ddlStates.addEventListener( ListEvent.CHANGE, cbStatesChangeHandler );
			}
		}
		
		
		
		/**
		 *  @inheritDoc
		 * 
		 */		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if (instance == ddlSkins )
			{
				ddlSkins.removeEventListener( ListEvent.CHANGE, cbSkinsChangeHandler );
			}
			else if (instance == ddlStates )
			{
				ddlStates.removeEventListener( ListEvent.CHANGE, cbStatesChangeHandler );
			}
			
			super.partRemoved(partName, instance);
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		// callbacks
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Callback for listening changes of selected skins
		 * @param 	event		ListEvent dispatched by cbStates
		 * 
		 */			
		protected function cbSkinsChangeHandler(event:IndexChangeEvent):void
		{
			selectedSkin = DropDownList( event.target ).selectedItem as Skin;
		}
		
		
		/**
		 * Callback for listening changes of selected states
		 * @param 	event		ListEvent dispatched by cbStates
		 * 
		 */		
		protected function cbStatesChangeHandler(event:IndexChangeEvent):void
		{
			selectedSkin.currentState = State( DropDownList( event.target ).selectedItem ).name;
		}		
		
		
		//--------------------------------------------------------------------------
		//
		// skin handling
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Helper method to get all skin states of selected skin 
		 * 
		 */		
		protected function changeSkinStates():void
		{
			
			skinStates = new ArrayList( selectedSkin.states.slice() );
			
			skinStatesChanged = true;
			
			invalidateProperties();
			
			
		}
		
		
		/**
		 * Adding a new skin 
		 * @param 	skin			Instance of a skin
		 * @param 	isSelectedSkin	Flag to set new added skin as a selected skin
		 * 
		 */		
		public function addSkin( skin: Skin, isSelectedSkin: Boolean = true ):void
		{
			//
			// avoid using double skins
			if ( _skins.getItemIndex( skin ) > -1 )
				return;
			
			
			//
			// Some skins needs a reference to its HostComponent
			// It have to add manually, because WSSkinStatesTester has references to skins only (without its HostComponents).
			var hostComponentName: String = hasHostComponent( skin );
			
			if( skin.hasOwnProperty('hostComponent') && hostComponentName!= null )
			{
				if( skin["hostComponent"] == null )
				{
					var hostComponentClass: * = getDefinitionByName( hostComponentName ); 
					
					try{
						skin["hostComponent"] = new hostComponentClass();		
					}
					catch( error: Error )
					{
						throw new Error("Unable to create a HostComponent using " + hostComponentName );
					}
					
				}
			}
			
			_skins.addItem( skin );	
			
			
			if( isSelectedSkin )
				selectedSkin = skin;
			
		}
		
		
		/**
		 * Removing a skin 
		 * @param 	skin 	Instance of a skin
		 * 
		 */		
		public function removeSkin( skin: Skin ):void
		{
			if ( selectedSkin == skin )
			{
				skinHolder.removeElement( skin );
				_selectedSkin = null;
			}
			
			_skins.removeItemAt( _skins.getItemIndex( skin ) );
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		// getter / setter
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Getter for selected skin 
		 * @return 	Skin		Selected Skin
		 * 
		 */		
		public function get selectedSkin():Skin
		{
			return _selectedSkin;
		}
		
		/**
		 * Setter method for selected Skin 
		 * @param 	value		Selected Skin
		 * 
		 */		
		public function set selectedSkin(value:Skin):void
		{
			if ( selectedSkin != null )
				skinHolder.removeElement( selectedSkin );
			
			_selectedSkin = value;
			
			if ( value != null )
			{			
				// set back to its first state
				selectedSkin.currentState = State( selectedSkin.states[0] ).name;
				// add to skin holder
				skinHolder.addElement( selectedSkin );
				// get all skin states
				changeSkinStates();
				// set selected skin
				if ( ddlSkins.selectedItem !== _selectedSkin )
					ddlSkins.selectedItem = _selectedSkin;	
				
			}
			
		}
		
		
		/**
		 * Setter method for new skins 
		 * @param newSkins		Array of new skins
		 * 
		 */		
		[ArrayElementType("spark.components.supportClasses.Skin")]
		public function set skins( newSkins: Array):void
		{
			//
			// clear old skins just creating an empty AC
			_skins = new ArrayList();
			// clear selectedSkin
			selectedSkin = null;
			
			// add new skins using addSkin method
			for each( var skin: Skin in newSkins )
			{
				addSkin( skin, false );
			}
			
			skinsChanged = true;
			
			invalidateProperties();
			
		}
		
		
		/**
		 * Getter for project url 
		 * @return 	String		URL of project page
		 * 
		 */		
		public function get projectURL():String
		{
			return URL;
		}
		
		
		/**
		 * Getter for current version 
		 * @return 	String		current version
		 * 
		 */		
		public function get version():String
		{
			return VERSION;
		}
		
		//--------------------------------------------------------------------------
		//
		// helper methods
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 * Helper method to get the nam of a skin class 
		 * @param 	skin		Instance of a skin
		 * @return 	String		Class name of a skin
		 * 
		 */		
		protected function getSkinClassName(skin: Skin):String
		{
			var className:String = getQualifiedClassName( skin );
			
			var index:int = className.indexOf("::");
			if (index != -1)
				className = className.substr(index + 2);
			
			return className;
			
		}
		
		
		/**
		 * Helper method to get the name of a state 
		 * @param 	item	Instance of a state
		 * @return 	String	Name of the state
		 * 
		 */		
		protected function getStateName(item: Object):String
		{
			var stateName: String = 'state not found';
			
			if( item is State )
				stateName = State( item ).name;
			
			return stateName;
			
		}
		
		/**
		 * Helper method to get the name of the HostComonent of a skin which is defined using Metatag declaration within Skin class 
		 * @param 	skin		Instance of a skin
		 * @return 	String		ClassName of the HostComponent
		 * 
		 */		
		protected function hasHostComponent( skin: Skin ):String
		{
			var description:XML = flash.utils.describeType( skin );		
			
			var meta:XMLList = description.metadata.(@name == "HostComponent");
			
			if ( meta.length() > 0 )
			{
				return meta[0].arg.@value;
			}
			
			return null;
			
		}
		
		
	}
}