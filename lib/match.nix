value: cases: default:
if builtins.hasAttr value cases then builtins.getAttr value cases else default
