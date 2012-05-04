# Field data.
couples = []
judges = []
dances = []

# Mark input data for each dance, couple, and judge.
marks = []

# Add listeners to all buttons.
$ ->
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
  $('#judgeMarksGen').click ->
    generateJudgeMarks()
  $('#coupleMarksGen').click ->
    generateCoupleMarks()
  $('#pasteinButton').click ->
    pastein()

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

test_addCouple = (number, name) ->
  idx = couples.length
  addCouple()
  $('#coupleFields .numberInput').last().val(number)
  $('#coupleFields .nameInput').last().val(name)
  couples[idx].number = number
  couples[idx].name = name

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

test_addJudge = (number, name) ->
  idx = judges.length
  addJudge()
  $('#judgeFields .numberInput').last().val(number)
  $('#judgeFields .nameInput').last().val(name)
  judges[idx].number = number
  judges[idx].name = name

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

test_addDance = (number, name) ->
  idx = dances.length
  addDance()
  $('#danceFields .numberInput').last().val(number)
  $('#danceFields .nameInput').last().val(name)
  dances[idx].number = number
  dances[idx].name = name

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

test_addMarks = (newMarks) ->
  generateMarks()

  numDances = newMarks.length
  numCouples = newMarks[0].length
  numJudges = newMarks[0][0].length
  # TODO: Validation vs current entries.

  markList = []
  for d in [0..numDances-1]
    for c in [0..numCouples-1]
      for j in [0..numJudges-1]
        markList.push newMarks[d][c][j]
        marks[d][c][j] = newMarks[d][c][j]

  counter = 0
  $('#marks input').each (index) ->
    $(this).val(markList[counter++])
  # TODO Validate and show error message if bad.

# Confirm that marks data is valid; that is, each judge gives all
# marks from 1 to numCouples for each dance.
validateMarks = ->
  # Check that marks table exists.
  if marks.length < 1 or marks[0].length < 1 or marks[0][0].length < 1
    return false
  # Check that judge marks span all possible places.
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

calculateJudgeMarks = ->
  judgeMarks = []
      #marks[danceIdx][coupleIdx][judgeIdx] = this.value
  numDances = marks.length
  numCouples = marks[0].length
  numJudges = marks[0][0].length
  for j in [0..numJudges-1]
    judgeMarks[j] = []
    for c in [0..numCouples-1]
      markSum = 0
      for d in [0..numDances-1]
        markSum += parseInt marks[d][c][j]
      judgeMarks[j][c] = markSum
  return judgeMarks

sortJudgeMarks = (judgeMarks) ->
  sortedMarks = []
  for judgeMark, idx in judgeMarks
    sortedMarks.push
      name: couples[idx].name
      mark: judgeMark
  sortedMarks.sort (a, b) ->
    if a.mark < b.mark
      return -1
    if a.mark > b.mark
      return 1
    return 0
  return sortedMarks

generateJudgeMarks = ->
  return unless validateMarks()

  # x judges, c couples
  # for each judge, show all c couples
  # look through marks table to get columns for each judge, for each judge.
  # keep judge, couple = score
  # at end, each judge should have different scores for each couple
  # for each judge, order the couples
  judgeMarks = calculateJudgeMarks()
  # Should be 2d array, first is judge (in order) and second is couple (in order). value is score
  # Now, for each judge, take in couple marks, and then associate each entry, sorted, wth couple name/num/index and score
  # Also, gen html.
  $('#judgeMarks').empty()
  for judge, judgeIdx in judgeMarks
    judgeHtml = "<table><tr><th></th><th>#{judges[judgeIdx].name}</th></tr>"
    sortedCouples = sortJudgeMarks judge
    for couple in sortedCouples
      judgeHtml += "<tr><td>#{couple.name}</td><td>#{couple.mark}</td></tr>"
    judgeHtml += "</table>"
    $('#judgeMarks').append judgeHtml



calculateCoupleMarks = ->
  coupleMarks = []
      #marks[danceIdx][coupleIdx][judgeIdx] = this.value
  numDances = marks.length
  numCouples = marks[0].length
  numJudges = marks[0][0].length
  for c in [0..numCouples-1]
    coupleMarks[c] = []
    for j in [0..numJudges-1]
      markSum = 0
      for d in [0..numDances-1]
        markSum += parseInt marks[d][c][j]
      coupleMarks[c][j] = markSum
  return coupleMarks

sortCoupleMarks = (coupleMarks) ->
  sortedMarks = []
  for coupleMark, idx in coupleMarks
    sortedMarks.push
      name: judges[idx].name
      mark: coupleMark
  sortedMarks.sort (a, b) ->
    if a.mark < b.mark
      return -1
    if a.mark > b.mark
      return 1
    return 0
  return sortedMarks


generateCoupleMarks = ->
  return unless validateMarks()

  coupleMarks = calculateCoupleMarks()
  $('#coupleMarks').empty()
  for couple, coupleIdx in coupleMarks
    coupleHtml = "<table><tr><th></th><th>#{couples[coupleIdx].name}</th></tr>"
    sortedJudges = sortCoupleMarks couple
    for judge in sortedJudges
      coupleHtml += "<tr><td>#{judge.name}</td><td>#{judge.mark}</td></tr>"
    coupleHtml += "</table>"
    $('#coupleMarks').append coupleHtml

pastein = ->
  pasteStr = $('#pastein').val()
  pageType = $('#pasteinSelect').val()
  switch pageType
    when "o2cm" then pasteinO2cm pasteStr
    when "danceresults" then pasteinDanceresults pasteStr

pasteinDanceresults = (pasteStr) ->
  judgeRe = /(Judge Name(?:.|\n)*)/g
  judgeArr = judgeRe.exec pasteStr
  tmp = judgeArr[1].split '\n'
  #console.log tmp

  totalJudges = 0
  # Loop over judges until end text is seen.
  endText = "Skip Navigation Links."
  linesToSkip = 1
  for line in tmp
    if linesToSkip > 0
      linesToSkip--
      continue
    if line == endText
      break
    splitLine = line.split '\t'
    test_addJudge splitLine[0], splitLine[1]
    totalJudges++

  # Get everything else. Couples first
  totalCouples = 0
  markRe = /(Dance:(?:.|\n)*)/g
  markArr = markRe.exec pasteStr
  tmp = markArr[1].split '\n'

  # Couples.
  linesToSkip = 3
  for line in tmp
    if linesToSkip > 0
      linesToSkip--
      continue
    if line == ""
      break
    splitLine = line.split '\t'
    test_addCouple splitLine[0], "#{splitLine[1]} & #{splitLine[2]}"
    totalCouples++

  # Dances and marks.
  newMarks = []
  linesToSkip = 1
  gotDance = false
  danceIdx = -1
  for line in tmp
    if linesToSkip > 0
      linesToSkip--
      continue
    if not gotDance
      if line == "Final Results"
        break
      danceCode = line.charAt(0)
      test_addDance danceCode, line
      danceIdx++
      newMarks[danceIdx] = []
      gotDance = true
      linesToSkip = 1
      coupleIdx = 0
    else
      # In a couple loop. 
      if line == ""
        # End couple loop, next is a dance or end.
        gotDance = false
      else
        # first 3 are not marks.
        newMarks[danceIdx][coupleIdx] = []
        splitLine = line.split '\t'
        lastJudgePos = totalJudges - 1 + 3
        for judgePos in [3..lastJudgePos]
          judgeIdx = judgePos - 3
          newMarks[danceIdx][coupleIdx][judgeIdx] = splitLine[judgePos]
        coupleIdx++
  test_addMarks newMarks


pasteinO2cm = (pasteStr) ->
  # O2CM: Get couple and judge lines.
  coupleRe = /(Couples(?:.|\n)*)/g
  coupleArr = coupleRe.exec pasteStr
  tmp = coupleArr[1].split '\n'

  coupleToIndex = {}

  # Parse couples and judges.
  parsingCouples = true
  linesToSkip = 1
  totalCouples = 0
  totalJudges = 0
  for line in tmp
    if linesToSkip > 0
      linesToSkip--
      continue
    splitLine = line.split '\t'
    number = parseInt splitLine[0]
    if isNaN(number)
      if parsingCouples
        parsingCouples = false
        linesToSkip = 1
      else
        break
    else
      if parsingCouples
        test_addCouple splitLine[0], splitLine[1]
        coupleToIndex[splitLine[0]] = totalCouples
        totalCouples++
      else
        test_addJudge splitLine[0], splitLine[1]
        totalJudges++

  newMarks = []
  #console.log pasteStr.split '\n'
  tmp = pasteStr.split '\n'
  linesToSkip = 2
  gotDance = false
  coupleCounter = -1
  danceIdx = -1
  coupleIdx = -1
  for line in tmp
    if linesToSkip > 0
      linesToSkip--
      continue
    if not gotDance
      if line == "Summary" || line.trim() == "Couples"
        break
      danceCode = line.charAt(0)
      test_addDance danceCode, line
      danceIdx++
      gotDance = true
      linesToSkip = 1
      coupleCounter = totalCouples
      newMarks[danceIdx] = []
      coupleIdx = -1
    else
      # On a couple line.
      splitLine = line.split '\t'
      # Find couple index if out of order.
      coupleIdx = coupleToIndex[splitLine[0]]
      #coupleIdx++
      newMarks[danceIdx][coupleIdx] = []
      #console.log "judges #{totalJudges}"
      #console.log splitLine
      for judgePos in [1..totalJudges]
        judgeIdx = judgePos - 1
        newMarks[danceIdx][coupleIdx][judgeIdx] = splitLine[judgePos]
      coupleCounter--
      if coupleCounter < 1
        gotDance = false
        linesToSkip = 1
  test_addMarks newMarks
