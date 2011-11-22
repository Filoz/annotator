clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance

class Annotator.Plugin.MarginViewerObjectStore
  constructor: (data=[] , funcObject , @idfield="id" , @marginobjfield="_marginobject" , @indexfield="_marginindex") ->
    tempObject = clone(funcObject)
    tempObject.sortComparison = (x,y) -> funcObject.sortComparison(x[0],y[0])
    tempObject.mapFunc = (x) -> [funcObject.sortDataMap(x),x]
    @data=data.map(tempObject.mapFunc)
    @data.sort(tempObject.sortComparison)
    @deletions=0
    @insertions=0
    for index in [0..@data.length-1]
      obj=@data[index][1]
      obj[@indexfield]=index
  
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
    funcObject =
      sortDataMap: (annotation) ->
        dbg = {top:annotation.highlights[0].offsetTop,left:annotation.highlights[0].offsetLeft}
        return dbg 
      sortComparison : (left,right) -> 
        return sign(sign(left.top - right.top)*2 + sign(left.left - right.left)*RTL_MULT)
      idFunction : (annotation) -> annotation.id
      sizeFunction : (element) -> element.outerHeight()
    @marginData = new Annotator.Plugin.MarginViewerObjectStore annotations,funcObject
    baseOffset = 50
    if annotations.length>0
      currentLocation = 0
      for annotation in @marginData.getMarginObjects()
        annotationStart = annotation.highlights[0]
        newLocation = annotationStart.offsetTop;
        if currentLocation>newLocation
          newLocation=currentLocation
        marginObjects=$('<div class="annotator-marginviewer-element">'+annotation.text+'</div>').appendTo('.secondary').css({position: 'absolute', top: newLocation+baseOffset+'px'})
        marginObject=marginObjects[0]
        annotation._marginObject=marginObject
        marginObject.annotation=annotation
        currentLocation = marginObject.offsetTop+$(marginObject).outerHeight(true)-baseOffset
    console.log(@marginData)

  onAnnotationCreated: (annotation) ->
    
  onAnnotationDeleted: (annotation) ->
    # do other stuff
    
  onAnnotationUpdated: (annotation) ->
    # yet more stuff
