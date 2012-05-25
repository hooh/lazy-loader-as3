package me.markezine.lazyloader.core
{
	import flash.system.LoaderContext;

	public dynamic class LazyLoaderVariables
	{
		/**
		 * The type of the file. If you omit this value, LazyLoader will try to identify it based 
		 * on the file extension.
		 */
		public var type:String;
		/**
		 * The id the item should be associated with. 
		 */
		public var id:String;
		/**
		 * The LoaderContext that should be used.
		 */
		public var context:LoaderContext; 
		
		/**
		 * Used to define the parameters object of an item.
		 * You can add dynamic parameters for searching in this class too. 
		 * @param id The id the item should be associated with. 
		 * @param context the LoaderContext that should be used.
		 * @param type The type of the file. If you omit this value, LazyLoader will try to identify
		 * it based on the file extension.
		 */
		public function LazyLoaderVariables(id:String = null, context:LoaderContext = null, type:String = null)
		{
			this.id = id;
			this.context = context;
			this.type = type;
		}
		
		internal function get forceType():String{
			return type;
		}
		
		internal function toObject():Object{
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