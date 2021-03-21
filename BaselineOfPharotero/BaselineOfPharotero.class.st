Class {
	#name : #BaselineOfPharotero,
	#superclass : #BaselineOf,
	#category : #BaselineOfPharotero
}

{ #category : #baselines }
BaselineOfPharotero >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec baseline: 'Neo-JSON-Core' with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
		spec package: 'Pharotero'  with: [ spec requires: #('Neo-JSON-Core') ]				
	].

]
