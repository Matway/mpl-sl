# Copyright (C) 2023 Matway Burkow
#
# This repository and all its contents belong to Matway Burkow (referred here and below as "the owner").
# The content is for demonstration purposes only.
# It is forbidden to use the content or any part of it for any purpose without explicit permission from the owner.
# By contributing to the repository, contributors acknowledge that ownership of their work transfers to the owner.

"control.&&" use
"control.||" use

"control.assignable?"    use
"control.automatic?"     use
"control.callable?"      use
"control.copyable?"      use
"control.creatable?"     use
"control.initializable?" use
"control.int?"           use
"control.movable?"       use
"control.nat?"           use
"control.number?"        use
"control.real?"          use
"control.ref?"           use
"control.sized?"         use
"control.virtualizable?" use

testObjectTraits: [
  NAMES: [("isCombined" "assignable?" "@automatic?" "callable?" "copyable?" "creatable?" "initializable?" "isConst" "isDirty" "isDynamic" "isStatic" "movable?" "ref?" "sized?" "virtual?" "virtualizable?" "code?" "codeRef?" "int?" "nat?" "number?" "real?")];
  CODES: [([isCombined] @assignable?   @automatic?  @callable?  @copyable?  @creatable?  @initializable?  [isConst] [isDirty] [isDynamic] [isStatic] @movable?  @ref?  @sized?  [virtual?] @virtualizable?  [code?] [codeRef?] @int?  @nat?  @number?  @real? )];

  checkTraits: [
    expression: results:;;
    i: 0; [
      i results fieldCount = [FALSE] [
        @expression ucall i CODES @ ucall i results @ = [] [
          "Invalid trait \"" i NAMES @ & "\"" & raiseStaticError
        ] if

        i 1 + !i
        TRUE
      ] if
    ] loop
  ];

  #                                                                                                              comb  assig autom call  copy  creat init  const dirty dynam stat  move  refer sized virt1 virt2 codeb coder int   nat   numb  real
  [TRUE v:; @v new                                                                                            ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [TRUE                                                                                                       ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [TRUE v:; @v                                                                                                ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [TRUE v:; @v const                                                                                          ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [TRUE dynamic v:; @v new                                                                                    ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [TRUE dynamic                                                                                               ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [TRUE dynamic v:; @v                                                                                        ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [TRUE dynamic v:; @v const                                                                                  ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [TRUE v:; 0nx @v addressToReference                                                                         ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [TRUE v:; 0nx @v const addressToReference                                                                   ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [0n8 v:; @v new                                                                                             ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n8                                                                                                        ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n8 v:; @v                                                                                                 ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n8 v:; @v const                                                                                           ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n8 dynamic v:; @v new                                                                                     ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n8 dynamic                                                                                                ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n8 dynamic v:; @v                                                                                         ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n8 dynamic v:; @v const                                                                                   ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n8 v:; 0nx @v addressToReference                                                                          ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n8 v:; 0nx @v const addressToReference                                                                    ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n16 v:; @v new                                                                                            ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n16                                                                                                       ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n16 v:; @v                                                                                                ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n16 v:; @v const                                                                                          ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n16 dynamic v:; @v new                                                                                    ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n16 dynamic                                                                                               ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n16 dynamic v:; @v                                                                                        ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n16 dynamic v:; @v const                                                                                  ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n16 v:; 0nx @v addressToReference                                                                         ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n16 v:; 0nx @v const addressToReference                                                                   ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n32 v:; @v new                                                                                            ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n32                                                                                                       ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n32 v:; @v                                                                                                ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n32 v:; @v const                                                                                          ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n32 dynamic v:; @v new                                                                                    ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n32 dynamic                                                                                               ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n32 dynamic v:; @v                                                                                        ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n32 dynamic v:; @v const                                                                                  ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n32 v:; 0nx @v addressToReference                                                                         ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n32 v:; 0nx @v const addressToReference                                                                   ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n64 v:; @v new                                                                                            ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n64                                                                                                       ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n64 v:; @v                                                                                                ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n64 v:; @v const                                                                                          ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n64 dynamic v:; @v new                                                                                    ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n64 dynamic                                                                                               ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n64 dynamic v:; @v                                                                                        ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n64 dynamic v:; @v const                                                                                  ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n64 v:; 0nx @v addressToReference                                                                         ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0n64 v:; 0nx @v const addressToReference                                                                   ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0nx v:; @v new                                                                                             ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0nx                                                                                                        ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0nx v:; @v                                                                                                 ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0nx v:; @v const                                                                                           ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0nx dynamic v:; @v new                                                                                     ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0nx dynamic                                                                                                ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0nx dynamic v:; @v                                                                                         ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0nx dynamic v:; @v const                                                                                   ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0nx v:; 0nx @v addressToReference                                                                          ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0nx v:; 0nx @v const addressToReference                                                                    ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE) checkTraits
  [0i8 v:; @v new                                                                                             ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i8                                                                                                        ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i8 v:; @v                                                                                                 ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i8 v:; @v const                                                                                           ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i8 dynamic v:; @v new                                                                                     ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i8 dynamic                                                                                                ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i8 dynamic v:; @v                                                                                         ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i8 dynamic v:; @v const                                                                                   ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i8 v:; 0nx @v addressToReference                                                                          ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i8 v:; 0nx @v const addressToReference                                                                    ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i16 v:; @v new                                                                                            ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i16                                                                                                       ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i16 v:; @v                                                                                                ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i16 v:; @v const                                                                                          ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i16 dynamic v:; @v new                                                                                    ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i16 dynamic                                                                                               ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i16 dynamic v:; @v                                                                                        ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i16 dynamic v:; @v const                                                                                  ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i16 v:; 0nx @v addressToReference                                                                         ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i16 v:; 0nx @v const addressToReference                                                                   ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0 v:; @v new                                                                                               ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0                                                                                                          ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0 v:; @v                                                                                                   ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0 v:; @v const                                                                                             ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0 dynamic v:; @v new                                                                                       ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0 dynamic                                                                                                  ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0 dynamic v:; @v                                                                                           ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0 dynamic v:; @v const                                                                                     ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0 v:; 0nx @v addressToReference                                                                            ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0 v:; 0nx @v const addressToReference                                                                      ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i64 v:; @v new                                                                                            ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i64                                                                                                       ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i64 v:; @v                                                                                                ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i64 v:; @v const                                                                                          ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i64 dynamic v:; @v new                                                                                    ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i64 dynamic                                                                                               ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i64 dynamic v:; @v                                                                                        ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i64 dynamic v:; @v const                                                                                  ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i64 v:; 0nx @v addressToReference                                                                         ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0i64 v:; 0nx @v const addressToReference                                                                   ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0ix v:; @v new                                                                                             ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0ix                                                                                                        ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0ix v:; @v                                                                                                 ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0ix v:; @v const                                                                                           ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0ix dynamic v:; @v new                                                                                     ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0ix dynamic                                                                                                ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0ix dynamic v:; @v                                                                                         ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0ix dynamic v:; @v const                                                                                   ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0ix v:; 0nx @v addressToReference                                                                          ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0ix v:; 0nx @v const addressToReference                                                                    ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE) checkTraits
  [0.0r32 v:; @v new                                                                                          ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r32                                                                                                     ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r32 v:; @v                                                                                              ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r32 v:; @v const                                                                                        ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r32 dynamic v:; @v new                                                                                  ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r32 dynamic                                                                                             ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r32 dynamic v:; @v                                                                                      ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r32 dynamic v:; @v const                                                                                ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r32 v:; 0nx @v addressToReference                                                                       ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r32 v:; 0nx @v const addressToReference                                                                 ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r64 v:; @v new                                                                                          ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r64                                                                                                     ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r64 v:; @v                                                                                              ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r64 v:; @v const                                                                                        ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r64 dynamic v:; @v new                                                                                  ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r64 dynamic                                                                                             ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r64 dynamic v:; @v                                                                                      ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r64 dynamic v:; @v const                                                                                ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r64 v:; 0nx @v addressToReference                                                                       ] (FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [0.0r64 v:; 0nx @v const addressToReference                                                                 ] (FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE ) checkTraits
  [[] v:; @v                                                                                                  ] (FALSE TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[]                                                                                                         ] (FALSE TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[] v:; @v const                                                                                            ] (FALSE TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{} {} {} codeRef                                                                                           ] (FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE) checkTraits
  [{} {} {} codeRef dynamic                                                                                   ] (FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE) checkTraits
  [{} {} {} codeRef v:; 0nx @v addressToReference                                                             ] (FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE) checkTraits
  [""                                                                                                         ] (FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  ["" dynamic                                                                                                 ] (FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  ["" v:; 0nx @v addressToReference                                                                           ] (FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  #                                                                                                              comb  assig autom call  copy  creat init  const dirty dynam stat  move  refer sized virt1 virt2 codeb coder int   nat   numb  real
  [{}                                                                                                         ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{} v:; @v const                                                                                            ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{v: 0;}                                                                                                    ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{v: 0;} v:; @v const] call                                                                                ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{v: 0;} v:; @v                                                                                             ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{v: 0;} v:; @v const                                                                                       ] (TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{v: 0;} v:; 0nx @v addressToReference                                                                      ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{v: 0;} v:; 0nx @v const addressToReference                                                                ] (TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {};}                                                                                               ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {};} v:; @v const                                                                                  ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {v: 0;};}                                                                                          ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{child: {v: 0;};} v:; @v const] call                                                                      ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {v: 0;};} v:; @v                                                                                   ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {v: 0;};} v:; @v const                                                                             ] (TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {v: 0;};} v:; 0nx @v addressToReference                                                            ] (TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {v: 0;};} v:; 0nx @v const addressToReference                                                      ] (TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: [];};}                                                                                       ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{child: {DIE: [];};} v:; @v const] call                                                                   ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: [];};} v:; @v                                                                                ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: [];};} v:; @v const                                                                          ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: [];}; v: 0;}                                                                                 ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{child: {DIE: [];}; v: 0;} v:; @v const] call                                                             ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: [];}; v: 0;} v:; @v                                                                          ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: [];}; v: 0;} v:; @v const                                                                    ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: [];}; v: 0;} v:; 0nx @v addressToReference                                                   ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: [];}; v: 0;} v:; 0nx @v const addressToReference                                             ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: []; INIT: [];};}                                                                             ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{child: {DIE: []; INIT: [];};} v:; @v const] call                                                         ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: []; INIT: [];};} v:; @v                                                                      ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: []; INIT: [];};} v:; @v const                                                                ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: []; INIT: [];}; v: 0;}                                                                       ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{child: {DIE: []; INIT: [];}; v: 0;} v:; @v const] call                                                   ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: []; INIT: [];}; v: 0;} v:; @v                                                                ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: []; INIT: [];}; v: 0;} v:; @v const                                                          ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: []; INIT: [];}; v: 0;} v:; 0nx @v addressToReference                                         ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {DIE: []; INIT: [];}; v: 0;} v:; 0nx @v const addressToReference                                   ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {ASSIGN: [o:;]; DIE: []; v: 0;};}                                                                  ] (TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{child: {ASSIGN: [o:;]; DIE: []; v: 0;};} v:; @v const] call                                              ] (TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {ASSIGN: [o:;]; DIE: []; v: 0;};} v:; @v                                                           ] (TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {ASSIGN: [o:;]; DIE: []; v: 0;};} v:; 0nx @v addressToReference                                    ] (TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};}                                                        ] (TRUE  TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};} v:; @v const] call                                    ] (TRUE  TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};} v:; @v                                                 ] (TRUE  TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};} v:; @v const                                           ] (TRUE  FALSE TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};} v:; 0nx @v addressToReference                          ] (TRUE  TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};} v:; 0nx @v const addressToReference                    ] (TRUE  FALSE TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: [];}                                                                                                 ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{DIE: [];} v:; @v const] call                                                                             ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: [];} v:; @v                                                                                          ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: [];} v:; @v const                                                                                    ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; v: 0;}                                                                                           ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{DIE: []; v: 0;} v:; @v const] call                                                                       ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; v: 0;} v:; @v                                                                                    ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; v: 0;} v:; @v const                                                                              ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; v: 0;} v:; 0nx @v addressToReference                                                             ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; v: 0;} v:; 0nx @v const addressToReference                                                       ] (TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; INIT: [];}                                                                                       ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{DIE: []; INIT: [];} v:; @v const] call                                                                   ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; INIT: [];} v:; @v                                                                                ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; INIT: [];} v:; @v const                                                                          ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; INIT: []; v: 0;}                                                                                 ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{DIE: []; INIT: []; v: 0;} v:; @v const] call                                                             ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; INIT: []; v: 0;} v:; @v                                                                          ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; INIT: []; v: 0;} v:; @v const                                                                    ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; INIT: []; v: 0;} v:; 0nx @v addressToReference                                                   ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{DIE: []; INIT: []; v: 0;} v:; 0nx @v const addressToReference                                             ] (TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: [];}                                                                                                ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: [];} v:; @v const                                                                                   ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; v: 0;}                                                                                          ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; v: 0;} v:; @v const] call                                                                      ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; v: 0;} v:; @v                                                                                   ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; v: 0;} v:; @v const                                                                             ] (TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; v: 0;} v:; 0nx @v addressToReference                                                            ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; v: 0;} v:; 0nx @v const addressToReference                                                      ] (TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {};}                                                                                     ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {};} v:; @v const                                                                        ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {v: 0;};}                                                                                ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; child: {v: 0;};} v:; @v const] call                                                            ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {v: 0;};} v:; @v                                                                         ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {v: 0;};} v:; @v const                                                                   ] (TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {v: 0;};} v:; 0nx @v addressToReference                                                  ] (TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {v: 0;};} v:; 0nx @v const addressToReference                                            ] (TRUE  FALSE FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: [];};}                                                                             ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; child: {DIE: [];};} v:; @v const] call                                                         ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: [];};} v:; @v                                                                      ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: [];};} v:; @v const                                                                ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: [];}; v: 0;}                                                                       ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; child: {DIE: [];}; v: 0;} v:; @v const] call                                                   ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: [];}; v: 0;} v:; @v                                                                ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: [];}; v: 0;} v:; @v const                                                          ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: [];}; v: 0;} v:; 0nx @v addressToReference                                         ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: [];}; v: 0;} v:; 0nx @v const addressToReference                                   ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: []; INIT: [];};}                                                                   ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; child: {DIE: []; INIT: [];};} v:; @v const] call                                               ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: []; INIT: [];};} v:; @v                                                            ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: []; INIT: [];};} v:; @v const                                                      ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: []; INIT: [];}; v: 0;}                                                             ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; child: {DIE: []; INIT: [];}; v: 0;} v:; @v const] call                                         ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: []; INIT: [];}; v: 0;} v:; @v                                                      ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: []; INIT: [];}; v: 0;} v:; @v const                                                ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: []; INIT: [];}; v: 0;} v:; 0nx @v addressToReference                               ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {DIE: []; INIT: [];}; v: 0;} v:; 0nx @v const addressToReference                         ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {ASSIGN: [o:;]; DIE: []; v: 0;};}                                                        ] (TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; child: {ASSIGN: [o:;]; DIE: []; v: 0;};} v:; @v const] call                                    ] (TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {ASSIGN: [o:;]; DIE: []; v: 0;};} v:; @v                                                 ] (TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {ASSIGN: [o:;]; DIE: []; v: 0;};} v:; 0nx @v addressToReference                          ] (TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};}                                              ] (TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};} v:; @v const] call                          ] (TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};} v:; @v                                       ] (TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};} v:; @v const                                 ] (TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};} v:; 0nx @v addressToReference                ] (TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; child: {ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;};} v:; 0nx @v const addressToReference          ] (TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: [];}                                                                                       ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; DIE: [];} v:; @v const] call                                                                   ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: [];} v:; @v                                                                                ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: [];} v:; @v const                                                                          ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; v: 0;}                                                                                 ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; DIE: []; v: 0;} v:; @v const] call                                                             ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; v: 0;} v:; @v                                                                          ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; v: 0;} v:; @v const                                                                    ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; v: 0;} v:; 0nx @v addressToReference                                                   ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; v: 0;} v:; 0nx @v const addressToReference                                             ] (TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; INIT: [];}                                                                             ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; DIE: []; INIT: [];} v:; @v const] call                                                         ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; INIT: [];} v:; @v                                                                      ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; INIT: [];} v:; @v const                                                                ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; INIT: []; v: 0;}                                                                       ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{CALL: []; DIE: []; INIT: []; v: 0;} v:; @v const] call                                                   ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; INIT: []; v: 0;} v:; @v                                                                ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; INIT: []; v: 0;} v:; @v const                                                          ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; INIT: []; v: 0;} v:; 0nx @v addressToReference                                         ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{CALL: []; DIE: []; INIT: []; v: 0;} v:; 0nx @v const addressToReference                                   ] (TRUE  FALSE TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; DIE: []; v: 0;}                                                                            ] (TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{ASSIGN: [o:;]; DIE: []; v: 0;} v:; @v const] call                                                        ] (TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; DIE: []; v: 0;} v:; @v                                                                     ] (TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; DIE: []; v: 0;} v:; 0nx @v addressToReference                                              ] (TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;}                                                                  ] (TRUE  TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;} v:; @v const] call                                              ] (TRUE  TRUE  TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;} v:; @v                                                           ] (TRUE  TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;} v:; @v const                                                     ] (TRUE  FALSE TRUE  FALSE TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;} v:; 0nx @v addressToReference                                    ] (TRUE  TRUE  TRUE  FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; DIE: []; INIT: []; v: 0;} v:; 0nx @v const addressToReference                              ] (TRUE  FALSE TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; CALL: []; DIE: []; v: 0;}                                                                  ] (TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{ASSIGN: [o:;]; CALL: []; DIE: []; v: 0;} v:; @v const] call                                              ] (TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; CALL: []; DIE: []; v: 0;} v:; @v                                                           ] (TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; CALL: []; DIE: []; v: 0;} v:; 0nx @v addressToReference                                    ] (TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE FALSE TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; CALL: []; DIE: []; INIT: []; v: 0;}                                                        ] (TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [[{ASSIGN: [o:;]; CALL: []; DIE: []; INIT: []; v: 0;} v:; @v const] call                                    ] (TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; CALL: []; DIE: []; INIT: []; v: 0;} v:; @v                                                 ] (TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; CALL: []; DIE: []; INIT: []; v: 0;} v:; @v const                                           ] (TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE TRUE  FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; CALL: []; DIE: []; INIT: []; v: 0;} v:; 0nx @v addressToReference                          ] (TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE TRUE  TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  [{ASSIGN: [o:;]; CALL: []; DIE: []; INIT: []; v: 0;} v:; 0nx @v const addressToReference                    ] (TRUE  FALSE TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  FALSE FALSE FALSE TRUE  TRUE  FALSE TRUE  FALSE FALSE FALSE FALSE FALSE FALSE) checkTraits
  #                                                                                                              comb  assig autom call  copy  creat init  const dirty dynam stat  move  refer sized virt1 virt2 codeb coder int   nat   numb  real
];

testObjectTraits

assignable?: [
  v:;
  @v isConst [FALSE] [
    @v isCombined ~ [TRUE] [
      @v "DIE" has [
        @v virtual? ~ [@v "ASSIGN" has] &&
      ] [
        i: 0; [
          i @v fieldCount = [TRUE FALSE] [
            @v i fieldIsRef ~ [@v i fieldRead assignable? ~] && [FALSE FALSE] [
              i 1 + !i
              TRUE
            ] if
          ] if
        ] loop
      ] if
    ] if
  ] if
];

code?: [
  v:;
  @v isCombined [FALSE] [
    @v virtual?
  ] if
];

codeRef?: [
  v:;
  @v isCombined [FALSE] [
    @v TRUE same [FALSE] [
      @v number? [FALSE] [
        @v "" same [FALSE] [
          @v code? ~
        ] if
      ] if
    ] if
  ] if
];

copyable?: [
  v:;
  @v isCombined [
    @v "DIE" has [
      @v virtual? [@v "INIT" has ~ [@v "ASSIGN" has ~] ||] || [FALSE] [
        i: 0; [
          i @v fieldCount = [TRUE FALSE] [
            @v i fieldIsRef ~ [@v i fieldRead initializable? ~] && [FALSE FALSE] [
              i 1 + !i
              TRUE
            ] if
          ] if
        ] loop
      ] if
    ] [
      i: 0; [
        i @v fieldCount = [TRUE FALSE] [
          @v i fieldIsRef ~ [@v i fieldRead copyable? ~] && [FALSE FALSE] [
            i 1 + !i
            TRUE
          ] if
        ] if
      ] loop
    ] if
  ] [
    @v TRUE same [@v number? [@v code?] ||] ||
  ] if

  #@v initializable? [@v unconst assignable?] &&
];

creatable?: [
  v:;
  @v isCombined [
    @v virtual? [TRUE] [
      @v "DIE" has [@v "INIT" has ~] && [FALSE] [
        i: 0; [
          i @v fieldCount = [TRUE FALSE] [
            @v i fieldIsRef ~ [@v i fieldRead initializable? ~] && [FALSE FALSE] [
              i 1 + !i
              TRUE
            ] if
          ] if
        ] loop
      ] if
    ] if
  ] [
    @v TRUE same [@v number? [@v code?] ||] ||
  ] if

  #@v virtual? [@v initializable?] ||
];

initializable?: [
  v:;
  @v isCombined ~ [TRUE] [
    @v "DIE" has [@v "INIT" has ~] && [FALSE] [
      i: 0; [
        i @v fieldCount = [TRUE FALSE] [
          @v i fieldIsRef ~ [@v i fieldRead initializable? ~] && [FALSE FALSE] [
            i 1 + !i
            TRUE
          ] if
        ] if
      ] loop
    ] if
  ] if
];

movable?: [
  v:;
  @v isConst [FALSE] [
    @v isCombined ~ [TRUE] [
      @v virtual? [
        @v automatic? ~
      ] [
        @v initializable?
      ] if
    ] if
  ] if

  #movable?: [v:; FALSE];
  #movable?: {PRE: [v:; 1nx @v addressToReference 1nx @v addressToReference set TRUE]; CALL: [v:; TRUE];};
  #movable?: {PRE: [v:; @v @v set TRUE]; CALL: [v:; TRUE];};
  #@v movable?
];

sized?: [
  v:;
  sized?: {CALL: [v:; FALSE];};
  sized?: {PRE: [storageSize TRUE]; CALL: [v:; TRUE];};
  @v sized?
];

virtual?: [
  v:;
  #{v:;} storageSize 0nx =
  virtual?: [v:; TRUE];
  #virtual?: {PRE: [v:; 0nx @v addressToReference TRUE]; CALL: [v:; FALSE];};
  virtual?: {PRE: [storageAddress TRUE]; CALL: [v:; FALSE];};
  @v virtual?
];

virtualizable?: [
  v:;
  @v isCombined ~ [@v virtual? ~ [@v automatic? ~] ||] ||
];

testObjectTraits
