# Field data.
couples = []
judges = []
dances = []

# Mark input data for each dance, couple, and judge.
marks = []

# Add listeners to all buttons.
$ ->
  $('h1').click ->
    $(this).hide 'slow'
  $('#coupleAdd').click ->
    addCouple()
  $('#coupleRemove').click ->
    removeCouple()
  $('#judgeAdd').click ->
    addJudge()
  $('#judgeRemove').click ->
    removeJudge()
  $('#danceAdd').click ->
    addDance()
  $('#danceRemove').click ->
    removeDance()
  $('#marksGen').click ->
    generateMarks()
  $('#interGen').click ->
    generateInter()

# Add a couple field and create a new input element. Set a focusout
# callback on update the couples array.
addCouple = ->
  newDivContent = '<div><input type="text" class="numberInput">'
  newDivContent += '<input type="text" class="nameInput">'
  newDivContent += '<br /></div>'
  $('#coupleFields').append newDivContent

  couples.push {number: "", name: ""}

  thisIndex = couples.length - 1
  $('#coupleFields .numberInput').last().focusout ->
    couples[thisIndex].number = this.value
  $('#coupleFields .nameInput').last().focusout ->
    couples[thisIndex].name = this.value

# Remove the couple field.
removeCouple = ->
  return if couples.length < 1

  couples.pop()
  $('#coupleFields div:last').remove()


# Add a judge field and create a new input element. Set a focusout
# callback on update the judges array.
addJudge = ->
  newDivContent = '<div><input type="text" class="numberInput">'
  newDivContent += '<input type="text" class="nameInput">'
  newDivContent += '<br /></div>'
  $('#judgeFields').append newDivContent

  judges.push {number: "", name: ""}

  thisIndex = judges.length - 1
  $('#judgeFields .numberInput').last().focusout ->
    judges[thisIndex].number = this.value
  $('#judgeFields .nameInput').last().focusout ->
    judges[thisIndex].name = this.value

# Remove the judge field.
removeJudge = ->
  return if judges.length < 1

  judges.pop()
  $('#judgeFields div:last').remove()

# Add a dance field and create a new input element. Set a focusout
# callback on update the dance array.
addDance = ->
  newDivContent = '<div><input type="text" class="numberInput">'
  newDivContent += '<input type="text" class="nameInput">'
  newDivContent += '<br /></div>'
  $('#danceFields').append newDivContent

  dances.push {number: "", name: ""}

  thisIndex = dances.length - 1
  $('#danceFields .numberInput').last().focusout ->
    dances[thisIndex].number = this.value
  $('#danceFields .nameInput').last().focusout ->
    dances[thisIndex].name = this.value

# Remove the dance field.
removeDance = ->
  return if dances.length < 1

  dances.pop()
  $('#danceFields div:last').remove()

# Make the marks table for each dance, based on the dance, couple,
# and judge fields. Set focusout callbacks in each input element to
# update the marks 3D array.
generateMarks = ->
  return if couples.length < 1 or judges.length < 1 or dances.length < 1

  $('#marks').empty()
  marks = []

  for dance in dances
    marks.push []
    danceIdx = marks.length - 1
    newTable = '<div><h3>' + dance.name + '</h3>'
    newTable += '<table><tr><th></th>'
    for judge in judges
      newTable += '<th>' + judge.number + '</th>'
    newTable += '</tr>'
    for couple in couples
      marks[danceIdx].push []
      coupleIdx = marks[danceIdx].length - 1
      newTable += '<tr><td>' + couple.number + '</td>'
      for judge in judges
        marks[danceIdx][coupleIdx].push ""
        newTable += '<td><input type="text"></td>'
    newTable += '</table><br /></div>'
    $('#marks').append newTable

  $('#marks input').each (index) ->
    $(this).focusout ->
      judgeIdx = index % judges.length
      coupleIdx = (Math.floor(index / judges.length)) % couples.length
      danceIdx = Math.floor(index / (couples.length * judges.length))
      marks[danceIdx][coupleIdx][judgeIdx] = this.value

# Confirm that marks data is valid; that is, each judge gives all
# marks from 1 to numCouples for each dance.
validateMarks = ->
  for dance, danceIdx in marks
    lastCouple = dance.length - 1
    lastJudge = dance[0].length - 1
    for judgeIdx in [0..lastJudge]
      markTracker = (false for i in [0..lastCouple])
      for coupleIdx in [0..lastCouple]
        mark = parseInt dance[coupleIdx][judgeIdx]
        if mark >= 1 and mark <= lastCouple+1
          markTracker[mark-1] = true
        else
          return false
      return false for m in markTracker when not m
  return true

# Applies the individual dance rules to calculate the dance placings.
# Also formats the intermediate table fields.
calculateInter = (maxSums) ->
  majority = Math.floor(marks[0][0].length / 2) + 1
  lastDance = marks.length - 1
  lastCouple = marks[0].length - 1
  lastJudge = marks[0][0].length - 1
  currentPlace = 1
  # algo
  # try to find the max for each col
  # keep track of the current place to place
  # if max exists and majority or over, choose as result = currentPlace++
  # repeat for next max and majority
  # if tie and majority, calculate future values.
  # to proceed, do a pass to get the counts of all
  # start at 0 and work up
  # if tie, then use marks[dance][couple][judge] to count sum for all < certain num
  # keep track of still in game: keep a list of indices to check (couples)

  ###
  inter = []
  for dance, danceIdx in marks
    inter.push []
    for rowIdx in [0..lastCouple]
      inter[danceIdx].push []
      for colIdx in [0..lastCouple]
        inter[danceIdx][rowIdx].push 0
  ###
  inter = []
  for dance, danceIdx in marks
    inter.push []
    for rowIdx in [0..lastCouple]
      inter[danceIdx].push []
      for colIdx in [0..lastCouple]
        inter[danceIdx][rowIdx].push("#{ maxSums[danceIdx][colIdx][rowIdx].max } (#{ maxSums[danceIdx][colIdx][rowIdx].sum })")
  return inter

# Creates a helper data structure that contains counts and sums for
# each placing for each couple and dance.
calculateMaxSums = ->
  # First, figure out the counts for each place.
  placeCounts = []
  lastCouple = marks[0].length - 1

  for dance, danceIdx in marks
    placeCounts.push []
    for coupleIdx in [0..lastCouple]
      placeCounts[danceIdx].push []
      for placeIdx in [0..lastCouple]
        placeCounts[danceIdx][coupleIdx].push 0
  for dance, danceIdx in marks
    for couple, coupleIdx in dance
      for mark, judgeIdx in couple
        markIdx = mark - 1
        placeCounts[danceIdx][coupleIdx][markIdx]++

  maxSums = []
  for dance, danceIdx in marks
    maxSums.push []
    maxSums[danceIdx].push []
    for coupleIdx in [0..lastCouple]
      maxSums[danceIdx][0].push
        max: placeCounts[danceIdx][coupleIdx][0]
        sum: placeCounts[danceIdx][coupleIdx][0] * 1
    if lastCouple > 0
      for placeIdx in [1..lastCouple]
        maxSums[danceIdx].push []
        for coupleIdx in [0..lastCouple]
          maxSums[danceIdx][placeIdx].push
            max: placeCounts[danceIdx][coupleIdx][placeIdx] + maxSums[danceIdx][placeIdx-1][coupleIdx].max
            sum: placeCounts[danceIdx][coupleIdx][placeIdx] * (placeIdx+1) + maxSums[danceIdx][placeIdx-1][coupleIdx].sum
  return maxSums
      
# Format the intermediate table with the result calculations.
generateInter = ->
  return unless validateMarks()

  maxSums = calculateMaxSums()
  inter = calculateInter maxSums

  $('#inter').empty()
  for dance, danceIdx in marks
    lastCouple = dance.length - 1
    interDiv = "<div>"
    interDiv += '<table><tr>'
    interDiv += '<th>1</th>'
    if lastCouple >= 1
      for coupleIdx in [1..lastCouple]
        interDiv += '<th>1-' + (coupleIdx+1) + '</th>'
    interDiv += '<th>P</th></tr>'
    for rowIdx in [0..lastCouple]
      interDiv += '<tr>'
      for colIdx in [0..lastCouple]
        interDiv += '<td>' + inter[danceIdx][rowIdx][colIdx] + '</td>'
      interDiv += '<td>FIN</td></tr>'
    interDiv += '</table><br /></div>'
    $('#inter').append interDiv
