clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance

class Annotator.Plugin.MarginViewerObjectStore
  constructor: (data=[] , @funcObject , @idfield="id" , @marginobjfield="_marginObject" , @indexfield="_marginindex") ->
    tempObject = clone(@funcObject)
    tempObject.sortComparison = (x,y) => @funcObject.sortComparison(x[0],y[0])
    tempObject.mapFunc = (x) => [@funcObject.sortDataMap(x),x]
    @data=data.map(tempObject.mapFunc)
    @data.sort(tempObject.sortComparison)
    @deletions=0
    @insertions=0
    for index in [0..@data.length-1]
      obj=@data[index][1]
      obj[@indexfield]=index
  
  getMarginObjects: -> @data.map((x) -> x[1])

  updateObjectLocation: (obj) ->
    objIndex = @getObjectLocation(obj)
    @data[objIndex]=[@funcObject.sortDataMap(obj),obj]
    
  getObjectLocation: (obj) -> 
    supposedLocation = obj[@indexfield]
    # object is at its internally stored location
    if @data[supposedLocation][1].id = obj.id
      return supposedLocation
    minimumIndex=Math.max(0,@deletions)
    maximumIndex=Math.min(@data.length+1,@insertions)

    for index in [minimumIndex..maximumindex]
      currentObject = @data[index][1]
      if currentObject.id = obj.id
        currentObject[@indexField]=index 
        return index
    return -1

  getNewLocationsForObject : (top,bottom,marginObject) ->
    objectIndex = @getObjectLocation(marginObject.annotation)
    currentIndex = objectIndex-1
    currentNewTop = top
    currentNewBottom = bottom
    locationChanges=[]
    # get preceding objects that need to be moved
    while currentIndex>=0
      currentObject=@data[currentIndex][1][@marginobjfield]
      currentObjectBottom=$(currentObject).offset().top+$(currentObject).outerHeight(true)
      if currentObjectBottom>currentNewTop
        objectNewTop=currentNewTop-$(currentObject).outerHeight(true)
        locationChanges.push([objectNewTop,currentObject])
        currentNewTop=objectNewTop
      else
        break
      currentIndex-=1
    # get succeeding objects that need to be moved
    currentIndex = objectIndex+1
    while currentIndex<@data.length
      currentObject=@data[currentIndex][1][@marginobjfield]
      currentObjectTop=$(currentObject).offset().top
      if currentObjectTop<currentNewBottom
        objectNewTop=currentNewBottom
        locationChanges.push([objectNewTop,currentObject])
        currentNewBottom=objectNewTop+$(currentObject).outerHeight(true)
      else
        break
      currentIndex+=1
    return locationChanges

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
        dbg = {top:$(annotation.highlights[0]).offset().top,left:$(annotation.highlights[0]).offset().left}
        return dbg 
      sortComparison : (left,right) -> 
        return sign(sign(left.top - right.top)*2 + sign(left.left - right.left)*RTL_MULT)
      idFunction : (annotation) -> annotation.id
      sizeFunction : (element) -> element.outerHeight(true)
    @marginData = new Annotator.Plugin.MarginViewerObjectStore annotations,funcObject
    if annotations.length>0
      currentLocation = 0
      for annotation in @marginData.getMarginObjects()
        annotationStart = annotation.highlights[0]
        newLocation = $(annotationStart).offset().top;
        if currentLocation>newLocation
          newLocation=currentLocation
        marginObjects=$('<div class="annotator-marginviewer-element">'+annotation.text+'</div>').appendTo('.secondary').offset({top: newLocation}).click((event) => @onAnnotationSelected(event.target))
        marginObject=marginObjects[0]
        annotation._marginObject=marginObject
        marginObject.annotation=annotation
        @marginData.updateObjectLocation(annotation)
        currentLocation = $(marginObject).offset().top+$(marginObject).outerHeight(true)

  onAnnotationCreated: (annotation) ->
    # do other stuff
     
  onAnnotationDeleted: (annotation) ->
    # do other stuff
    
  onAnnotationUpdated: (annotation) ->
    # yet more stuff

  onAnnotationSelected: (marginObject) ->
    annotation = marginObject.annotation
    newTop = $(annotation.highlights[0]).offset().top
    newBottom = $(marginObject).outerHeight(true)+newTop
    newLocationsByObject = @marginData.getNewLocationsForObject(newTop,newBottom,marginObject)
    newLocationsByObject.push([newTop,marginObject])
    for newLocationStructure in newLocationsByObject
      newTop = newLocationStructure[0]
      currentObject = newLocationStructure[1]
      $(currentObject).animate({top:"+="+(newTop-$(currentObject).offset().top)},'fast','swing')
      @marginData.updateObjectLocation(currentObject.annotation)
