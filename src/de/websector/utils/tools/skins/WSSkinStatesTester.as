package de.websector.utils.tools.skins
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.events.ListEvent;
	import mx.states.State;
	
	import spark.components.Group;
	import spark.components.SkinnableContainer;
	import spark.components.supportClasses.Skin;
	
	/**
	* Testing states of skin classes in Flex 4 using WSSkinStatesTester
	* 
	* @author	Jens Krause [www.websector.de]
	* @date		09/06/09
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
		protected var _skins: ArrayCollection = new ArrayCollection();
		
		/**
		 * List of all skinStates of selected skin 
		 * 
		 */		
		protected var skinStates: ArrayCollection = new ArrayCollection();	

		/**
		 * ComboBox for selecting skins, which is a required part of the skin
		 *  
		 */		
		[SkinPart(required="true")]
		public var cbSkins: ComboBox;
		
		/**
		 * ComboBox for selecting states, which is a required part of the skin
		 *  
		 */			
		[SkinPart(required="true")]
		public var cbStates: ComboBox;

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
		public static const VERSION: String = "v.0.2";
		
		/**
		 *  Constructor 
		 *  
		 */	
		public function WSSkinStatesTester()
		{
			super();
			
			//
			// default skin class
			if( getStyle('skinClass') == undefined )
				setStyle("skinClass", de.websector.utils.tools.skins.WSSkinStatesTesterSkin );
		}
		
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
			
			if ( cbSkins != null && skinsChanged )
			{				
				cbSkins.dataProvider = _skins;
				selectedSkin = _skins.getItemAt( 0 ) as Skin;
				
				skinsChanged = false;
			}
			
			if ( cbStates != null && skinStatesChanged )
			{				
				cbStates.dataProvider = skinStates;
				
				//
				// FIXME: It seems to be a bug of Flex 4, 
				// because the dropdown of ComboBox is not updated by itself 
				if ( cbStates.dropdown != null )
					cbStates.dropdown.dataProvider = skinStates;
				
				skinStatesChanged = false;
			}
		}
		
		/**
		 *  @inheritDoc
		 * 
		 */			
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == cbSkins )
			{
				cbSkins.dataProvider = _skins;
				cbSkins.labelFunction = getSkinClassName;
				cbSkins.addEventListener( ListEvent.CHANGE, cbSkinsChangeHandler );
			}
			else if (instance == cbStates )
			{
				cbStates.dataProvider = skinStates;
				cbStates.labelFunction = getStateName;
				cbStates.addEventListener( ListEvent.CHANGE, cbStatesChangeHandler );
			}
		}
		
		

	    /**
	     *  @inheritDoc
		 * 
		 */		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if (instance == cbSkins )
			{
				cbSkins.removeEventListener( ListEvent.CHANGE, cbSkinsChangeHandler );
			}
			else if (instance == cbStates )
			{
				cbStates.removeEventListener( ListEvent.CHANGE, cbStatesChangeHandler );
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
		protected function cbSkinsChangeHandler(event:ListEvent):void
		{
			selectedSkin = ComboBox( event.target ).selectedItem as Skin;
		}
		
		
		/**
		 * Callback for listening changes of selected states
		 * @param 	event		ListEvent dispatched by cbStates
		 * 
		 */		
		protected function cbStatesChangeHandler(event:ListEvent):void
		{
			selectedSkin.currentState = ComboBox( event.target ).selectedLabel;
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
			
			skinStates = new ArrayCollection( selectedSkin.states.slice() );

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
				var hostComponentClass: * = getDefinitionByName( hostComponentName ); 
				
				try{
					skin["hostComponent"] = new hostComponentClass();		
				}
				catch( error: Error )
				{
					throw new Error("Unable to create a HostComponent using " + hostComponentName );
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
				if ( cbSkins.selectedItem != _selectedSkin )
					cbSkins.selectedItem = _selectedSkin;	
			
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
			_skins = new ArrayCollection();
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