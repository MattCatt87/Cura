from typing import Any, Optional

from UM.Decorators import override
from UM.Logger import Logger
from UM.Settings.Interfaces import PropertyEvaluationContext
from UM.Settings.ContainerStack import ContainerStack


class PerObjectContainerStack(ContainerStack):

    @override(ContainerStack)
    def getProperty(self, key: str, property_name: str, context: Optional[PropertyEvaluationContext] = None) -> Any:
        if context is None:
            context = PropertyEvaluationContext()
        context.pushContainer(self)

        # this import has to be here otherwise there will be a circular import loop
        from cura.CuraApplication import CuraApplication
        global_stack = CuraApplication.getInstance().getGlobalContainerStack()

        # Handle the "limit_to_extruder" property.
        limit_to_extruder = super().getProperty(key, "limit_to_extruder", context)
        if limit_to_extruder is not None:
            limit_to_extruder = str(limit_to_extruder)

        # if this stack has the limit_to_extruder "not overriden", use the original limit_to_extruder as the current
        # limit_to_extruder, so the values retrieved will be from the perspective of the original limit_to_extruder
        # stack.
        if limit_to_extruder == "-1":
            if 'original_limit_to_extruder' in context.context:
                limit_to_extruder = context.context['original_limit_to_extruder']

        if limit_to_extruder is not None and limit_to_extruder != "-1" and limit_to_extruder in global_stack.extruders:
            # set the original limit_to_extruder if this is the first stack that has a non-overriden limit_to_extruder
            if 'original_limit_to_extruder' not in context.context:
                context.context['original_limit_to_extruder'] = limit_to_extruder

            if super().getProperty(key, "settable_per_extruder", context):
                result = global_stack.extruders[str(limit_to_extruder)].getProperty(key, property_name, context)
                if result is not None:
                    context.popContainer()
                    return result
            else:
                Logger.log("e", "Setting {setting} has limit_to_extruder but is not settable per extruder!", setting = key)

        result = super().getProperty(key, property_name, context)
        context.popContainer()
        return result

