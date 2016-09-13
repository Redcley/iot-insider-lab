namespace WrapperExtensions
{
    using System;
    using System.Web.Mvc;
    using Validation;

    public class ModelStateWrapper : DefaultControllerFactory, IValidationDictionary
    {
        private ModelStateDictionary modelState;

        public ModelStateWrapper(ModelStateDictionary modelState)
        {
            this.modelState = modelState;
        }

        public void AddError(string key, string errorMessage)
        {
            if (!this.modelState.ContainsKey(key) || (this.modelState[key].Errors.Count == 0))
            {
                this.modelState.AddModelError(key, errorMessage);
            }
        }

        public void AddError(string key, Exception errorException)
        {
            if (!this.modelState.ContainsKey(key) || (this.modelState[key].Errors.Count == 0))
            {
                string errormsg = string.Empty;
                traiteException(errorException, out errormsg);

                this.modelState.AddModelError(key, errormsg);
            }
        }

        public void AddError(string errorMessage)
        {
            this.modelState.AddModelError(string.Empty, errorMessage);
        }

        public void AddError(Exception errorException)
        {
            string errormsg = string.Empty;
            traiteException(errorException, out errormsg);

            this.modelState.AddModelError(string.Empty, errormsg);
        }

        public bool IsValid
        {
            get { return this.modelState.IsValid; }
        }

        private void traiteException(Exception ex, out string erromsg)
        {
            if (ex.InnerException != null)
            {
                traiteException(ex.InnerException, out erromsg);
            }
            else
            {
                erromsg = ex.Message;
            }
        }
    }
}