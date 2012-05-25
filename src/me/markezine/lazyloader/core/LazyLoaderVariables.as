package me.markezine.lazyloader.core
{
	import flash.system.LoaderContext;

	public dynamic class LazyLoaderVariables
	{
		public var type:String;
		public var id:String;
		public var context:LoaderContext; 
		public var useWeakReference:Boolean;
		
		public function LazyLoaderVariables(id:String = null, context:LoaderContext = null, type:String = ItemType.AUTO)
		{
			this.id = id;
			this.context = context;
			this.type = type;
			this.useWeakReference = LazyLoader.useWeakReference;
		}
		
		internal function get forceType():String{
			return type;
		}
		
		public function toObject():Object{
			var result:Object = {};
			for(var i:String in this){
				result[i] = this[i];
			}
			
			result.id = this.id;
			result.context = this.context;
			result.type = this.type;
			result.forceType = this.type;
			result.useWeakReference = this.useWeakReference;
			
			return result;
		}
	}
}