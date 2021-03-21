Class {
	#name : #BaselineOfPharotero,
	#superclass : #BaselineOf,
	#category : #BaselineOfPharotero
}

{ #category : #baselines }
BaselineOfPharotero >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec baseline: 'NeoJSONCore' with: [ spec
			loads: 'Neo-JSON-Core';
			repository: 'github://svenvc/NeoJSON/repository' ].
		spec package: 'Pharotero'  with: [ spec requires: #('NeoJSONCore') ]				
	].

]
