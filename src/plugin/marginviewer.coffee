class Annotator.Plugin.MarginViewer.MarginObjectStore
  constructor: (data=[] , @_cmpdatafunc , _cmpfunc , @idfield="id" , @marginobjfield="_marginobject" , @indexfield="_marginindex") ->
    @cmpfunc=(x,y) -> _cmpfunc(x[0],y[0])
    mapfunc=(x) -> [@_cmpdatafunc(x),x]
    @data=data.map(mapfunc)
    @data.sort(cmpfunc)
    @deletions=0
    @insertions=0
    for index in [0..@data.length-1]
      @data[index][@_indexfield]=index
  
  getMarginObjects: -> @data.map((x) -> x[1])

  updateObjectLocation: (obj,newLocation) ->
    objIndex = this.getObjectLocation(obj)
    @data[objIndex]=[newLocation,obj]
    
  getObjectLocation: (obj) -> obj[@indexfield]

class Annotator.Plugin.MarginViewer extends Annotator.Plugin
  events:
    'annotationsLoaded': 'onAnnotationsLoaded'      
    'annotationCreated': 'onAnnotationCreated'      
    'annotationDeleted': 'onAnnotationDeleted'      
    'annotationUpdated': 'onAnnotationUpdated'      
            
  pluginInit: ->
    return unless Annotator.supported()
    @marginObjects = [] 
    @objectIndex = {}
    @annotator.viewer =
      on: ->
      hide: -> 
      load: ->
      isShown: ->
      element:
        css: ->
        position: ->
    
  onAnnotationsLoaded: (annotations) ->
    RTL_MULT = -1 #should be -1 if RTL else 1
    sign = (x) ->
      if(x==0)
        return 0
      else
        return x/Math.abs(x)
    getPos = (annotation) ->
      return {top:annotation.highlights[0].offsetTop,left:annotation.highlights[0].offsetLeft}
    sortfunc = (left,right) -> 
      return sign(sign(left.top - right.top)*2 + sign(left.left - right.left)*RTL_MULT)
    idfunc = (x) -> x.id
    @marginData = new MarginDataStore annotations getPos sortfunc
    for marginObjects in @marginData.getMarginObjects()
      $('<div class="annotator-marginviewer-element">'+annotation.text+'</div>').appendTo('.secondary').css({position: 'absolute', top: annotation.highlights[0].offsetTop+53+'px'})

  onAnnotationCreated: (annotation) ->
    
  onAnnotationDeleted: (annotation) ->
    # do other stuff
    
  onAnnotationUpdated: (annotation) ->
    # yet more stuff
